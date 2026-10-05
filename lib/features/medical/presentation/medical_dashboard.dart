import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../providers/medical_providers.dart';
import 'medical_theme.dart';

class MedicalDashboard extends ConsumerWidget {
  const MedicalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = MedicalTheme.background(context);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Health & Insurance'),
        backgroundColor: background,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('billDefaultsButton'),
            tooltip: 'Bill defaults',
            icon: const Icon(Icons.tune),
            onPressed: () => _editInsuranceProfile(context, ref),
          ),
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
            ..invalidate(medicalBillsProvider)
            ..invalidate(insuranceProfileProvider)
            ..invalidate(familyMembersProvider)
            ..invalidate(medicalProvidersProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _InsuranceSection(
                  onSetup: () => _editInsuranceProfile(context, ref)),
            ),
            const SliverToBoxAdapter(child: _BudgetImpactCard()),
            const SliverToBoxAdapter(child: _PatientShareCard()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Medical Bills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      key: const Key('addBillButton'),
                      onPressed: () => context.push('/medical_bill_form'),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.blueAccent.withAlpha(100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _BillsSliver(),
          ],
        ),
      ),
    );
  }

  Future<void> _editInsuranceProfile(
      BuildContext context, WidgetRef ref) async {
    final profileId = ref.read(activeProfileProvider).value?.id;
    final existing = profileId == null
        ? ref.read(insuranceProfileProvider).value
        : await ref
            .read(medicalRepositoryProvider)
            .getInsuranceProfile(profileId);

    if (!context.mounted) return;
    final result = await showModalBottomSheet<InsuranceProfile>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _InsuranceProfileSheet(initial: existing),
    );
    if (result == null) return;
    result.profileId = profileId;
    await ref.read(medicalRepositoryProvider).saveInsuranceProfile(result);
  }

  Future<void> _openDirectory(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _DirectorySheet(),
    );
  }
}

// -----------------------------------------------------------------------------
// Insurance profile
// -----------------------------------------------------------------------------

class _InsuranceSection extends ConsumerWidget {
  const _InsuranceSection({required this.onSetup});

  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insurance = ref.watch(insuranceProfileProvider);

    return insurance.when(
      data: (profile) {
        if (profile == null || !_isConfigured(profile)) {
          return _SetupPrompt(onSetup: onSetup);
        }
        // The gear used to be the only entry point to this setting, so its
        // effect was invisible once configured. One line makes it discoverable
        // without opening anything.
        return _DefaultsSummary(
          percent: profile.defaultPatientPercent,
          plan: profile.planSummary,
          onEdit: onSetup,
        );
      },
      loading: () => const SizedBox(height: 8),
      error: (_, __) => _SetupPrompt(onSetup: onSetup),
    );
  }

  /// FR-035: there is no deductible to configure any more, so a profile counts
  /// as configured once it carries a usable default patient share.
  static bool _isConfigured(InsuranceProfile p) => p.defaultPatientPercent > 0;
}

/// The configured state: shows the current default so the setting has a visible
/// representation on the screen, not just an icon in the app bar.
class _DefaultsSummary extends StatelessWidget {
  const _DefaultsSummary({
    required this.percent,
    required this.onEdit,
    this.plan,
  });

  final double percent;

  /// Already joined by `InsuranceProfile.planSummary`, so it is null when
  /// neither part was recorded.
  final String? plan;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        color: Colors.blueAccent.withValues(alpha: 0.12),
        child: ListTile(
          key: const Key('billDefaultsSummary'),
          leading: const Icon(Icons.tune, color: Colors.blueAccent),
          title: Text('Usually pay ${percent.toStringAsFixed(0)}%'),
          // Two separate lines rather than one '\n' string: the plan is a
          // distinct fact, not part of the explanation.
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plan != null) Text(plan!),
              const Text('Pre-filled on every new bill. Tap to change.'),
            ],
          ),
          isThreeLine: plan != null,
          trailing: const Icon(Icons.chevron_right),
          onTap: onEdit,
        ),
      ),
    );
  }
}

class _SetupPrompt extends StatelessWidget {
  const _SetupPrompt({required this.onSetup});

  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        color: Colors.blueAccent.withValues(alpha: 0.12),
        child: ListTile(
          leading: const Icon(Icons.shield_outlined, color: Colors.blueAccent),
          title: const Text('Set your usual share'),
          subtitle: const Text(
            'The share you normally pay, so new bills pre-fill it for you.',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onSetup,
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _patientShare = TextEditingController(
      text: (p?.defaultPatientPercent ?? 20).toStringAsFixed(0),
    );
    _insurer = TextEditingController(text: p?.insurerName ?? '');
    _plan = TextEditingController(text: p?.planName ?? '');
  }

  @override
  void dispose() {
    _patientShare.dispose();
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Usual patient share (%)',
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
    final parsed = double.tryParse(raw.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed < 0) return 'Cannot be negative';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final profile = widget.initial ?? InsuranceProfile();
    profile.defaultPatientPercent = double.parse(_patientShare.text.trim());
    profile.setPlanDetails(
      insurerName: _insurer.text,
      planName: _plan.text,
    );
    Navigator.of(context).pop(profile);
  }
}

// -----------------------------------------------------------------------------
// Patient share + budget impact
// -----------------------------------------------------------------------------

/// Month-scoped split of who paid what.
///
/// Replaces the old deductible progress card (FR-037): with deductibles gone
/// there is no limit or progress to show, only the totals for the selected month
/// (T049).
class _PatientShareCard extends ConsumerWidget {
  const _PatientShareCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(patientShareTotalsProvider);
    final symbol = ref.watch(medicalCurrencySymbolProvider);
    final month = ref.watch(selectedYearMonthProvider);

    if (totals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      key: const Key('patientShareCard'),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: MedicalTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient share',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${totals.billCount} bill'
              '${totals.billCount == 1 ? '' : 's'} in $month',
              style: TextStyle(color: MedicalTheme.subtleText(context)),
            ),
            const SizedBox(height: 16),
            _SplitRow(
              label: 'Billed',
              value: totals.billedTotal,
              currencySymbol: symbol,
              color: MedicalTheme.subtleText(context),
            ),
            _SplitRow(
              label: 'Insurer paid',
              value: totals.insurerPaidTotal,
              currencySymbol: symbol,
              color: Colors.green,
            ),
            _SplitRow(
              label: 'You paid',
              value: totals.patientShareTotal,
              currencySymbol: symbol,
              color: Colors.orange,
            ),
            if (totals.reimbursedTotal > 0) ...[
              _SplitRow(
                label: 'Reimbursed to you',
                value: totals.reimbursedTotal,
                currencySymbol: symbol,
                color: Colors.teal,
              ),
              _SplitRow(
                label: 'Net out of pocket',
                value: totals.netPatientCost,
                currencySymbol: symbol,
                color: Colors.red,
                bold: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.label,
    required this.value,
    required this.currencySymbol,
    required this.color,
    this.bold = false,
  });

  final String label;
  final double value;
  final String currencySymbol;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: bold ? base?.copyWith(fontWeight: FontWeight.bold) : base,
          ),
          Text(
            MedicalTheme.money(currencySymbol, value),
            style: base?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetImpactCard extends ConsumerWidget {
  const _BudgetImpactCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impact = ref.watch(medicalBudgetImpactProvider);
    final symbol = ref.watch(medicalCurrencySymbolProvider);

    if (impact.plannedTotal == 0 && impact.paidTotal == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: MedicalTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Impact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ImpactRow(
              label: 'Paid to providers',
              value: MedicalTheme.money(symbol, impact.paidTotal),
              color: Colors.redAccent,
            ),
            if (impact.hasPending)
              _ImpactRow(
                label: 'Still planned',
                value: MedicalTheme.money(symbol, impact.plannedTotal),
                color: Colors.orange,
              ),
            _ImpactRow(
              label: 'Estimated out-of-pocket',
              value: MedicalTheme.money(symbol, impact.outOfPocketTotal),
              color: Colors.blueAccent,
            ),
            if (impact.reimbursedTotal > 0)
              _ImpactRow(
                label: 'Reimbursed',
                value: '+${MedicalTheme.money(symbol, impact.reimbursedTotal)}',
                color: Colors.green,
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net cost to you',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: MedicalTheme.subtleText(context),
                  ),
                ),
                Text(
                  MedicalTheme.money(symbol, impact.netOutOfPocket),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  const _ImpactRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Bill list
// -----------------------------------------------------------------------------

class _BillsSliver extends ConsumerWidget {
  const _BillsSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(medicalBillsProvider);
    final symbol = ref.watch(medicalCurrencySymbolProvider);

    return billsAsync.when(
      data: (bills) {
        if (bills.isEmpty) {
          return SliverToBoxAdapter(
            child: _EmptyState(
              background: MedicalTheme.background(context),
            ),
          );
        }
        return SliverList.builder(
          itemCount: bills.length,
          itemBuilder: (context, index) => _BillTile(
            bill: bills[index],
            currencySymbol: symbol,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Could not load medical bills: $error'),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.background});

  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 48,
            color: MedicalTheme.subtleText(context),
          ),
          const SizedBox(height: 12),
          const Text(
            'No medical bills yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Log a bill to see what it costs you and what comes back.',
            textAlign: TextAlign.center,
            style: TextStyle(color: MedicalTheme.subtleText(context)),
          ),
        ],
      ),
    );
  }
}

class _BillTile extends ConsumerWidget {
  const _BillTile({required this.bill, required this.currencySymbol});

  final MedicalBill bill;
  final String currencySymbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(medicalDirectoryProvider);
    final provider = directory.providerName(bill.providerId);
    final patient = directory.memberName(bill.familyMemberId);

    // FR-042: the state is the single source of truth for both the chip colour
    // and the wording, so it replaces the old claim-status + paid/planned pair.
    final stateColor = MedicalTheme.billStateColor(context, bill.state);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: stateColor.withValues(alpha: 0.2),
        child: Icon(
          MedicalTheme.billStateIcon(bill.state),
          color: stateColor,
        ),
      ),
      title: Text(provider ?? 'Medical Bill'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            <String>[
              if (patient != null) patient,
              bill.state.label,
              bill.paymentMethod.label,
            ].join(' • '),
          ),
          if (bill.followUpDate != null && bill.state.isPending)
            Text(
              'Follow up ${DateFormat('MMM d').format(bill.followUpDate!)}',
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            MedicalTheme.money(currencySymbol, bill.billedAmount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          // FR-042: only an insurer-paid bill splits the charge; a self-paid one
          // is entirely the user's, so a share line would be misleading.
          if (bill.paymentMethod == MedicalPaymentMethod.insurerPaid)
            Text(
              '${MedicalTheme.money(currencySymbol, bill.patientShareAmount)} you',
              style: TextStyle(
                fontSize: 12,
                color: MedicalTheme.subtleText(context),
              ),
            ),
        ],
      ),
      onTap: () => context.push('/medical_detail', extra: bill.id),
    );
  }
}

// -----------------------------------------------------------------------------
// Provider + family directory (FR-008)
// -----------------------------------------------------------------------------

class _DirectorySheet extends ConsumerWidget {
  const _DirectorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(medicalProvidersProvider).value ?? const [];
    final members = ref.watch(familyMembersProvider).value ?? const [];

    return SafeArea(
      child: Padding(
        // The keyboard covers the lower half of the sheet, so the list needs the
        // inset as real space and a bounded parent to scroll within.
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Providers & Family',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  // Compact when the list is short, scrollable when it is long:
                  // the ConstrainedBox above gives this a bounded height to
                  // shrink-wrap against instead of the full screen.
                  shrinkWrap: true,
                  children: [
                    _DirectorySectionHeader(
                      title: 'Medical providers',
                      onAdd: () => _editProvider(context, ref),
                    ),
                    if (providers.isEmpty)
                      const _DirectoryEmpty('No providers saved yet.'),
                    for (final provider in providers)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.local_hospital_outlined),
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
                        onTap: () =>
                            _editProvider(context, ref, existing: provider),
                      ),
                    const Divider(height: 32),
                    _DirectorySectionHeader(
                      title: 'Family members',
                      onAdd: () => _editFamilyMember(context, ref),
                    ),
                    if (members.isEmpty)
                      const _DirectoryEmpty('No family members yet.'),
                    for (final member in members)
                      ListTile(
                        dense: true,
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
              const SizedBox(height: 16),
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
    final draft = await showModalBottomSheet<_ProviderDraft>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ProviderFormSheet(existing: existing),
    );
    if (draft == null) return;
    final profileId = ref.read(activeProfileProvider).value?.id;
    if (profileId == null) return;
    await ref.read(medicalRepositoryProvider).saveProvider(
          id: existing?.id,
          profileId: profileId,
          name: draft.name,
          specialty: draft.specialty,
        );
  }

  Future<void> _editFamilyMember(
    BuildContext context,
    WidgetRef ref, {
    FamilyMember? existing,
  }) async {
    final draft = await showModalBottomSheet<_FamilyMemberDraft>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FamilyMemberFormSheet(existing: existing),
    );
    if (draft == null) return;
    final profileId = ref.read(activeProfileProvider).value?.id;
    if (profileId == null) return;
    await ref.read(medicalRepositoryProvider).saveFamilyMember(
          id: existing?.id,
          profileId: profileId,
          name: draft.name,
          relation: draft.relation,
        );
  }
}

class _DirectorySectionHeader extends StatelessWidget {
  const _DirectorySectionHeader({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
      ],
    );
  }
}

class _DirectoryEmpty extends StatelessWidget {
  const _DirectoryEmpty(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: TextStyle(color: MedicalTheme.subtleText(context)),
      ),
    );
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
