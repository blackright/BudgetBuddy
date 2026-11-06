import '../providers/medical_receipt_provider.dart';
import 'package:flutter/material.dart';
import '../../../shared/presentation/modals/app_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/budget_context_provider.dart';
import '../../finance/presentation/receipt_boundary_review.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/providers/clock_provider.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../../dashboard/presentation/widgets/month_convert_to_menu.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/money_field.dart';
import '../providers/medical_providers.dart';
import '../repositories/medical_repository.dart';
import 'medical_bill_list_card.dart';
import 'medical_bill_view_state.dart';
import 'medical_empty_state.dart';
import 'medical_filter_bar.dart';
import 'medical_page_header.dart';
import 'medical_section_card.dart';
import 'medical_sheet_header.dart';
import 'medical_summary_card.dart';
import 'medical_theme.dart';

Future<void> reviewMedicalReceiptSetup(BuildContext context, WidgetRef ref,
        {bool balance = false, ContextRef? target}) =>
    reviewReceiptSetup(context, ref, balance: balance, target: target);

class MedicalDashboard extends ConsumerWidget {
  const MedicalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = MedicalTheme.background(context);
    final canEdit = ref.watch(activeContextCanEditProvider);
    final inbox = ref.watch(medicalInboxProvider);
    final filters = ref.watch(medicalInboxFiltersProvider);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 48,
        title: const Text('Health & Insurance'),
        backgroundColor: background,
        elevation: 0,
        actions: [
          if (ref.watch(activeContextCanManageProvider))
            PopupMenuButton<String>(
              tooltip: 'Medical options',
              onSelected: (value) => reviewMedicalReceiptSetup(context, ref,
                  balance: value == 'balanceReview'),
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'receiptSetup', child: Text('Review receipt setup')),
                PopupMenuItem(
                    value: 'balanceReview',
                    child: Text('Review opening money')),
              ],
            ),
          if (canEdit) const MonthConvertToMenu(),
          if (canEdit)
            IconButton(
              key: const Key('billDefaultsButton'),
              tooltip: 'Bill defaults',
              icon: const Icon(Icons.tune),
              onPressed: () => _editInsuranceProfile(context, ref),
            ),
          if (canEdit)
            IconButton(
              tooltip: 'Providers & family',
              icon: const Icon(Icons.groups_outlined),
              onPressed: () => _openDirectory(context, ref),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(medicalBillViewBatchProvider)
            ..invalidate(insuranceProfileProvider)
            ..invalidate(familyMembersProvider)
            ..invalidate(medicalProvidersProvider)
            ..invalidate(medicalServiceTypesProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: MedicalPageHeader(
                title: 'Medical bills',
                subtitle: 'Open bills across all months',
                trailing: ElevatedButton.icon(
                  key: const Key('addBillButton'),
                  onPressed:
                      canEdit ? () => context.push('/medical_bill_form') : null,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MedicalSummaryCard(
                needsYouCount: inbox.valueOrNull?.needsYouCount ?? 0,
                waitingCount:
                    inbox.valueOrNull?.count(MedicalInboxGroup.waiting) ?? 0,
                approvedStillToReceiveMinor:
                    inbox.valueOrNull?.approvedStillToReceiveMinor ?? 0,
                currency: ref.watch(medicalDisplayCurrencyProvider),
                mainCurrency: ref.watch(mainCurrencyProvider),
                rateTable: ref.watch(rateRegistryProvider).tableFor(
                      ref.watch(selectedYearMonthProvider),
                    ),
                amountsNeedReview:
                    inbox.valueOrNull?.amountsNeedReview ?? false,
                hasError: inbox.hasError,
              ),
            ),
            SliverToBoxAdapter(
              child: MedicalFilterBar(
                filters: filters,
                inbox: inbox.valueOrNull,
                onChanged: (value) => ref
                    .read(medicalInboxFiltersProvider.notifier)
                    .state = value,
                onClear: () => ref
                    .read(medicalInboxFiltersProvider.notifier)
                    .state = const MedicalInboxFilters(),
              ),
            ),
            ...inbox.when<List<Widget>>(
              data: (data) => data.items.isEmpty
                  ? [
                      SliverToBoxAdapter(
                        child: MedicalEmptyState(
                          icon: data.allBillsCount > 0
                              ? Icons.filter_alt_off_outlined
                              : Icons.medical_services_outlined,
                          title: data.allBillsCount > 0
                              ? 'No bills match these filters'
                              : 'No medical bills yet',
                          message: data.allBillsCount > 0
                              ? 'Clear a filter or choose another month.'
                              : 'Add a bill to see what it costs you and what comes back.',
                          actions: [
                            if (data.allBillsCount > 0)
                              TextButton(
                                key: const Key('medicalInboxEmptyClear'),
                                style: TextButton.styleFrom(
                                    minimumSize: const Size(48, 48)),
                                onPressed: () => ref
                                    .read(medicalInboxFiltersProvider.notifier)
                                    .state = const MedicalInboxFilters(),
                                child: const Text('Clear filters'),
                              )
                            else if (canEdit)
                              FilledButton.icon(
                                key: const Key('medicalInboxAddBill'),
                                style: FilledButton.styleFrom(
                                    minimumSize: const Size(48, 48)),
                                onPressed: () =>
                                    context.push('/medical_bill_form'),
                                icon: const Icon(Icons.add),
                                label: const Text('Add bill'),
                              ),
                          ],
                        ),
                      ),
                    ]
                  : [
                      SliverList.builder(
                        itemCount: data.items.length,
                        itemBuilder: (context, index) {
                          final item = data.items[index];
                          final bill = item.bill;
                          return MedicalBillListCard(
                            bill: bill,
                            state: item.state,
                            displayCurrency: data.currency,
                            rateTable: ref
                                .watch(rateRegistryProvider)
                                .tableFor(ref.watch(selectedYearMonthProvider)),
                            providerName: item.providerName,
                            memberName: item.memberName,
                            serviceTypeName: item.serviceTypeName,
                            now: ref.watch(clockProvider),
                            onOpen: () =>
                                context.push('/medical_detail', extra: bill.id),
                            onReviewSetup: () =>
                                _reviewBillSetup(context, ref, bill),
                          );
                        },
                      ),
                    ],
              loading: () => const [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
              error: (error, _) => [
                SliverToBoxAdapter(
                  child: MedicalEmptyState(
                    icon: Icons.error_outline,
                    title: 'Could not load medical bills',
                    message:
                        'Reopen this screen after checking your access and selected budget.',
                    isError: true,
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48)),
                        onPressed: () =>
                            ref.invalidate(medicalBillViewBatchProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reviewBillSetup(
      BuildContext context, WidgetRef ref, MedicalBill bill) async {
    final target = bill.sharedSpaceId == null
        ? ContextRef.personal(
            profileId: bill.profileId!, yearMonth: bill.yearMonth)
        : ContextRef.shared(
            spaceId: bill.sharedSpaceId!, yearMonth: bill.yearMonth);
    await reviewMedicalReceiptSetup(context, ref, target: target);
    if (!context.mounted) return;
    ref
      ..invalidate(medicalBillViewBatchProvider)
      ..invalidate(medicalBillMonthBlockersProvider(bill.id));
  }

  Future<void> _editInsuranceProfile(
      BuildContext context, WidgetRef ref) async {
    final profileId = ref.read(activeProfileProvider).value?.id;
    final spaceId = ref.read(activeSpaceIdProvider);
    // The active context owns the plan (FR-013): read back the same
    // context-scoped row the screen renders from, so editing inside a space
    // never opens — or overwrites — the personal plan.
    final existing = ref.read(insuranceProfileProvider).value;

    if (!context.mounted) return;
    final result = await showAppSheet<InsuranceProfile>(
      context,
      isScrollControlled: true,
      builder: (ctx) => _InsuranceProfileSheet(initial: existing),
    );
    if (result == null) return;
    result.profileId = profileId;
    await ref
        .read(medicalRepositoryProvider)
        .saveInsuranceProfile(result, sharedSpaceId: spaceId);
  }

  Future<void> _openDirectory(BuildContext context, WidgetRef ref) async {
    await showAppSheet<void>(
      context,
      isScrollControlled: true,
      builder: (ctx) => const _DirectorySheet(),
    );
  }
}

// -----------------------------------------------------------------------------
// Insurance profile
// -----------------------------------------------------------------------------

class _InsuranceProfileSheet extends StatefulWidget {
  const _InsuranceProfileSheet({this.initial});

  final InsuranceProfile? initial;

  @override
  State<_InsuranceProfileSheet> createState() => _InsuranceProfileSheetState();
}

class _InsuranceProfileSheetState extends State<_InsuranceProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _patientShare;
  late final TextEditingController _insurer;
  late final TextEditingController _plan;

  /// FR-009: the patient-share field is a percentage, not money — it selects
  /// all on focus but is never comma-grouped.
  late final FocusNode _patientShareFocus;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _patientShare = TextEditingController(
      text: (p?.defaultPatientPercent ?? 20).toStringAsFixed(0),
    );
    _patientShareFocus = selectAllOnFocus(_patientShare);
    _insurer = TextEditingController(text: p?.insurerName ?? '');
    _plan = TextEditingController(text: p?.planName ?? '');
  }

  @override
  void dispose() {
    _patientShare.dispose();
    _patientShareFocus.dispose();
    _insurer.dispose();
    _plan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        // The inset padding above lifts the sheet clear of the keyboard, but the
        // content can still be taller than the space that leaves. Scrolling it
        // means a tall sheet shrinks into the remaining room instead of
        // overflowing (FR: no RenderFlex overflow under a soft keyboard).
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bill Defaults',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Pre-fills every new bill. You can still change it per bill.',
                style: TextStyle(color: MedicalTheme.subtleText(context)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('defaultPatientShareField'),
                controller: _patientShare,
                focusNode: _patientShareFocus,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Usual Your share (%)',
                  helperText: 'The share you normally pay, not the insurer\'s. '
                      'A 20% share means a 1000 bill costs you 200.',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final error = _validateNumber(v);
                  if (error != null) return error;
                  final parsed = double.parse(v!);
                  if (parsed < 0 || parsed > 100) {
                    return 'Must be between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Your plan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Optional. Useful when a statement arrives and you need to tell '
                'which plan covered it.',
                style: TextStyle(color: MedicalTheme.subtleText(context)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('insurerNameField'),
                controller: _insurer,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Insurer (optional)',
                  hintText: 'e.g. Blue Cross',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('planNameField'),
                controller: _plan,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Plan name (optional)',
                  hintText: 'e.g. PPO 500',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
                onPressed: _submit,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateNumber(String? raw, {bool allowEmpty = false}) {
    if (raw == null || raw.trim().isEmpty) {
      return allowEmpty ? null : 'Required';
    }
    final parsed = parseMoneyInput(raw);
    if (parsed == null) return 'Enter a number';
    if (parsed < 0) return 'Cannot be negative';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final profile = widget.initial ?? InsuranceProfile();
    profile.defaultPatientPercent = parseMoneyInput(_patientShare.text) ?? 0;
    profile.setPlanDetails(
      insurerName: _insurer.text,
      planName: _plan.text,
    );
    Navigator.of(context).pop(profile);
  }
}

// -----------------------------------------------------------------------------
// Provider + family directory (FR-008)
// -----------------------------------------------------------------------------

class _DirectorySheet extends ConsumerStatefulWidget {
  const _DirectorySheet();

  @override
  ConsumerState<_DirectorySheet> createState() => _DirectorySheetState();
}

class _DirectorySheetState extends ConsumerState<_DirectorySheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    bool matches(String value) =>
        query.isEmpty || value.toLowerCase().contains(query);
    final providers = (ref.watch(medicalProvidersProvider).value ?? const [])
        .where((p) => matches(p.name) || matches(p.specialty ?? ''))
        .toList();
    final members = (ref.watch(familyMembersProvider).value ?? const [])
        .where((m) => matches(m.name) || matches(m.relation))
        .toList();
    final serviceTypes =
        (ref.watch(medicalServiceTypesProvider).value ?? const [])
            .where((t) => matches(t.name))
            .toList();
    final noMatches = query.isNotEmpty &&
        providers.isEmpty &&
        members.isEmpty &&
        serviceTypes.isEmpty;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            MedicalTheme.screenGutter,
            16,
            MedicalTheme.screenGutter,
            MediaQuery.viewInsetsOf(context).bottom + 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MedicalSheetHeader(
                title: 'Providers & family',
                subtitle: 'Names and service types used on bills.',
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('directorySearchField'),
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search provider, person or service type',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(MedicalTheme.inputRadius)),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (noMatches)
                      const MedicalEmptyState(
                        icon: Icons.search_off,
                        title: 'No matches',
                        message: 'Try another name or clear the search.',
                      )
                    else ...[
                      MedicalSectionCard(
                        title: 'Medical providers',
                        trailing: TextButton.icon(
                          key: const Key('addProviderButton'),
                          style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48)),
                          onPressed: () => _editProvider(context, ref),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                        child: providers.isEmpty
                            ? const Text('No providers saved yet.')
                            : Column(
                                children: [
                                  for (final provider in providers)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                          Icons.local_hospital_outlined),
                                      title: Text(provider.name),
                                      subtitle: provider.specialty == null
                                          ? null
                                          : Text(provider.specialty!),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: 'Remove provider',
                                        onPressed: () => ref
                                            .read(medicalRepositoryProvider)
                                            .deleteProvider(provider.id),
                                      ),
                                      onTap: () => _editProvider(context, ref,
                                          existing: provider),
                                    ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      MedicalSectionCard(
                        title: 'Family members',
                        trailing: TextButton.icon(
                          key: const Key('addFamilyMemberButton'),
                          style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48)),
                          onPressed: () => _editFamilyMember(context, ref),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                        child: members.isEmpty
                            ? const Text('No family members yet.')
                            : Column(
                                children: [
                                  for (final member in members)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.person_outline),
                                      title: Text(member.name),
                                      subtitle: Text(member.relation),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        tooltip: 'Remove member',
                                        onPressed: () => ref
                                            .read(medicalRepositoryProvider)
                                            .deleteFamilyMember(member.id),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      MedicalSectionCard(
                        title: 'Service types',
                        trailing: TextButton.icon(
                          key: const Key('addServiceTypeButton'),
                          style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48)),
                          onPressed: () => _editServiceType(context, ref),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                        child: serviceTypes.isEmpty
                            ? const Text('No service types yet.')
                            : Column(
                                children: [
                                  for (final type in serviceTypes)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(type.archived
                                          ? Icons.inventory_2_outlined
                                          : Icons.medical_services_outlined),
                                      title: Text(
                                        type.name,
                                        style: type.archived
                                            ? TextStyle(
                                                color: MedicalTheme.subtleText(
                                                    context))
                                            : null,
                                      ),
                                      subtitle: type.archived
                                          ? const Text('Archived')
                                          : null,
                                      trailing: IconButton(
                                        icon: Icon(type.archived
                                            ? Icons.unarchive_outlined
                                            : Icons.archive_outlined),
                                        tooltip: type.archived
                                            ? 'Restore service type'
                                            : 'Archive service type',
                                        onPressed: () => ref
                                            .read(medicalRepositoryProvider)
                                            .setServiceTypeArchived(type.id,
                                                archived: !type.archived),
                                      ),
                                      onTap: type.archived
                                          ? null
                                          : () => _editServiceType(context, ref,
                                              existing: type),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProvider(
    BuildContext context,
    WidgetRef ref, {
    MedicalProvider? existing,
  }) async {
    final draft = await showAppSheet<_ProviderDraft>(
      context,
      isScrollControlled: true,
      builder: (ctx) => _ProviderFormSheet(existing: existing),
    );
    if (draft == null) return;
    final profileId = ref.read(activeProfileProvider).value?.id;
    if (profileId == null) return;
    await ref.read(medicalRepositoryProvider).saveProvider(
          id: existing?.id,
          profileId: profileId,
          // FR-013: while a space is active the row must carry the space key,
          // or the space's own provider list can never show it.
          sharedSpaceId: ref.read(activeSpaceIdProvider),
          name: draft.name,
          specialty: draft.specialty,
        );
  }

  Future<void> _editFamilyMember(
    BuildContext context,
    WidgetRef ref, {
    FamilyMember? existing,
  }) async {
    final draft = await showAppSheet<_FamilyMemberDraft>(
      context,
      isScrollControlled: true,
      builder: (ctx) => _FamilyMemberFormSheet(existing: existing),
    );
    if (draft == null) return;
    final profileId = ref.read(activeProfileProvider).value?.id;
    if (profileId == null) return;
    await ref.read(medicalRepositoryProvider).saveFamilyMember(
          id: existing?.id,
          profileId: profileId,
          sharedSpaceId: ref.read(activeSpaceIdProvider),
          name: draft.name,
          relation: draft.relation,
        );
  }

  Future<void> _editServiceType(
    BuildContext context,
    WidgetRef ref, {
    MedicalServiceType? existing,
  }) async {
    final draft = await showAppSheet<_ServiceTypeDraft>(
      context,
      isScrollControlled: true,
      builder: (ctx) => _ServiceTypeFormSheet(existing: existing),
    );
    if (draft == null) return;
    final profileId = ref.read(activeProfileProvider).value?.id;
    if (profileId == null) return;
    try {
      await ref.read(medicalRepositoryProvider).saveServiceType(
            id: existing?.id,
            profileId: profileId,
            sharedSpaceId: ref.read(activeSpaceIdProvider),
            name: draft.name,
          );
    } on DuplicateServiceTypeException {
      // The repository rejects a case-insensitive duplicate (FR-040); surface it
      // instead of silently doing nothing.
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${draft.name}" is already a service type.')),
      );
    }
  }
}

class _ProviderDraft {
  const _ProviderDraft({required this.name, this.specialty});

  final String name;
  final String? specialty;
}

class _ProviderFormSheet extends StatefulWidget {
  const _ProviderFormSheet({this.existing});

  final MedicalProvider? existing;

  @override
  State<_ProviderFormSheet> createState() => _ProviderFormSheetState();
}

class _ProviderFormSheetState extends State<_ProviderFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _specialty;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _specialty = TextEditingController(text: widget.existing?.specialty ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _specialty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        // See _InsuranceProfileSheetState: scroll the content so a soft keyboard
        // cannot turn this into a RenderFlex overflow.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? 'Add Provider' : 'Edit Provider',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialty,
                decoration: const InputDecoration(
                  labelText: 'Specialty (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  final specialty = _specialty.text.trim();
                  Navigator.of(context).pop(
                    _ProviderDraft(
                      name: _name.text.trim(),
                      specialty: specialty.isEmpty ? null : specialty,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyMemberDraft {
  const _FamilyMemberDraft({required this.name, required this.relation});

  final String name;
  final String relation;
}

class _FamilyMemberFormSheet extends StatefulWidget {
  const _FamilyMemberFormSheet({this.existing});

  final FamilyMember? existing;

  @override
  State<_FamilyMemberFormSheet> createState() => _FamilyMemberFormSheetState();
}

class _FamilyMemberFormSheetState extends State<_FamilyMemberFormSheet> {
  static const _relations = <String>[
    'Self',
    'Spouse',
    'Partner',
    'Child',
    'Parent',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late String _relation;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _relation = widget.existing?.relation.isNotEmpty ?? false
        ? widget.existing!.relation
        : _relations.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        // See _InsuranceProfileSheetState: scroll the content so a soft keyboard
        // cannot turn this into a RenderFlex overflow.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? 'Add Family Member' : 'Edit Member',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _relation,
                decoration: const InputDecoration(
                  labelText: 'Relation',
                  border: OutlineInputBorder(),
                ),
                items: _relations
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _relation = v ?? _relations.first),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.of(context).pop(
                    _FamilyMemberDraft(
                      name: _name.text.trim(),
                      relation: _relation,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTypeDraft {
  const _ServiceTypeDraft({required this.name});

  final String name;
}

class _ServiceTypeFormSheet extends StatefulWidget {
  const _ServiceTypeFormSheet({this.existing});

  final MedicalServiceType? existing;

  @override
  State<_ServiceTypeFormSheet> createState() => _ServiceTypeFormSheetState();
}

class _ServiceTypeFormSheetState extends State<_ServiceTypeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: _formKey,
        // See _InsuranceProfileSheetState: scroll the content so a soft keyboard
        // cannot turn this into a RenderFlex overflow.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? 'Add Service Type'
                    : 'Rename Service Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('serviceTypeNameField'),
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('serviceTypeSaveButton'),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.of(context)
                      .pop(_ServiceTypeDraft(name: _name.text.trim()));
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
