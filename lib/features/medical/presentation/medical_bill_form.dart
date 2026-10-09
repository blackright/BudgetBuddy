import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../providers/medical_providers.dart';
import 'medical_theme.dart';

const String _newProviderSentinel = '__new_provider__';
const String _newMemberSentinel = '__new_member__';

/// Add / edit form for a single [MedicalBill] (T010).
///
/// Passing [existingBill] switches the form into edit mode; the linked expense
/// is updated in place so the engine's budget math stays consistent.
class MedicalBillForm extends ConsumerStatefulWidget {
  const MedicalBillForm({
    super.key,
    this.existingBill,
    this.initialPaidToProvider = false,
  });

  final MedicalBill? existingBill;

  /// Provider-payment state lives on the linked expense, not the bill, so it
  /// is handed in by the route once the join is resolved.
  final bool initialPaidToProvider;

  @override
  ConsumerState<MedicalBillForm> createState() => _MedicalBillFormState();
}

/// Route entry point that resolves a bill id into a loaded [MedicalBill].
///
/// go_router builders are synchronous, so the id cannot be turned into a model
/// there; this widget does the lookup and hands a ready model to the form.
class MedicalBillFormRoute extends ConsumerWidget {
  const MedicalBillFormRoute({super.key, this.billId});

  final int? billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = billId;
    if (id == null) return const MedicalBillForm();

    final billAsync = ref.watch(medicalBillProvider(id));
    return billAsync.when(
      data: (bill) {
        if (bill == null) {
          return const _RouteMessage(
            title: 'Medical Bill',
            message: 'This medical bill no longer exists.',
          );
        }
        final statuses = ref.watch(medicalExpenseStatusesProvider).value ??
            const <int, ExpenseStatus>{};
        return MedicalBillForm(
          existingBill: bill,
          initialPaidToProvider: isPaidToProvider(bill, statuses),
        );
      },
      loading: () => const _RouteMessage(
        title: 'Medical Bill',
        message: null,
        showSpinner: true,
      ),
      error: (error, _) => _RouteMessage(
        title: 'Medical Bill',
        message: 'Could not load this bill: $error',
      ),
    );
  }
}

class _RouteMessage extends StatelessWidget {
  const _RouteMessage({
    required this.title,
    required this.message,
    this.showSpinner = false,
  });

  final String title;
  final String? message;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: showSpinner
            ? const CircularProgressIndicator()
            : Text(message ?? '', textAlign: TextAlign.center),
      ),
    );
  }
}

class _MedicalBillFormState extends ConsumerState<MedicalBillForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _patientShareController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _reimbursementController = TextEditingController();

  int? _selectedProviderId;
  int? _selectedFamilyMemberId;
  int? _serviceTypeId;

  /// FR-041: the only two methods. Changes what the bill costs the budget.
  MedicalPaymentMethod _paymentMethod = MedicalPaymentMethod.selfPaid;

  /// The bill document. Optional either way (FR-047).
  String? _billPhotoPath;

  /// The insurer's reply. Self-paid bills only (FR-047, D2).
  String? _insurerReplyPath;

  DateTime _serviceDate = DateTime.now();

  /// FR-055: the bill belongs to its service month unless the user overrides it.
  String? _monthOverride;

  /// FR-053: `planned` keeps a bill out of payments entirely.
  MedicalBillState _state = MedicalBillState.waiting;

  CurrencyCode? _selectedCurrency;

  bool _saving = false;

  bool get _isEditing => widget.existingBill != null;

  /// Only a self-paid bill can be reimbursed (R-1).
  bool get _showReimbursementField =>
      _paymentMethod == MedicalPaymentMethod.selfPaid &&
      (_isEditing || _state == MedicalBillState.finished);

  @override
  void initState() {
    super.initState();
    final bill = widget.existingBill;
    if (bill == null) {
      _patientShareController.text = '20';
      return;
    }
    _amountController.text =
        Money(bill.billedAmount, bill.currencyCode ?? CurrencyCode.huf)
            .majorValue
            .toStringAsFixed(2);
    _patientShareController.text = bill.patientSharePercent.toStringAsFixed(0);
    _selectedProviderId = bill.providerId;
    _selectedFamilyMemberId = bill.familyMemberId;
    _serviceTypeId = bill.serviceTypeId;
    _paymentMethod = bill.paymentMethod;
    _billPhotoPath = bill.billPhotoPath;
    _insurerReplyPath = bill.insurerReplyPath;
    _serviceDate = bill.serviceDate ?? DateTime.now();
    _state = bill.state;
    _reimbursementController.text =
        (Money(bill.reimbursedAmount, bill.currencyCode ?? CurrencyCode.huf)
                .majorValue)
            .toStringAsFixed(2);
    _selectedCurrency = bill.currencyCode;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _patientShareController.dispose();
    _providerNameController.dispose();
    _memberNameController.dispose();
    _reimbursementController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------------
  // Documents (FR-047)
  // -----------------------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 2000,
      imageQuality: 85,
    );
    final path = file?.path;
    if (path == null || !mounted) return;
    setState(() => _billPhotoPath = path);
  }

  /// Picks the insurer's reply document, e.g. an EOB PDF.
  Future<void> _pickInsurerReply() async {
    // D2: an insurer reply only makes sense on a bill the user paid in full.
    if (_paymentMethod == MedicalPaymentMethod.insurerPaid) {
      _toast(
        'An insurer reply only applies to a self-paid bill. An insurer-paid '
        'bill is settled directly with the provider.',
      );
      return;
    }
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic'],
    );
    final path = file?.path;
    if (path == null || !mounted) return;
    setState(() => _insurerReplyPath = path);
  }

  Future<void> _pickMonthOverride() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
      helpText: 'Which month should this bill land in?',
    );
    if (picked == null || !mounted) return;
    setState(() => _monthOverride = DateFormat('yyyy-MM').format(picked));
  }

  // -----------------------------------------------------------------------------
  // Derived values (T013)
  // -----------------------------------------------------------------------------

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0.0;

  CurrencyCode get _currencyCode {
    if (_selectedCurrency != null) return _selectedCurrency!;
    final primary = ref.read(medicalBillContextProvider)?.primaryCurrency;
    return CurrencyCode.tryParse(primary ?? '') ?? CurrencyCode.huf;
  }

  int get _amountMinor => Money.fromMajor(_amount, _currencyCode).minorUnits;

  /// FR-048: the share the *user* pays, not the insurer's coverage.
  double get _patientSharePercent =>
      double.tryParse(_patientShareController.text.trim()) ?? 0.0;

  /// Live preview of the split while the user types, and what this bill will
  /// take from the budget.
  ///
  /// Uses the same [MedicalBill] rules the repository applies (R07) and returns
  /// whole **minor units** of the entered currency, so the preview, the stored
  /// amount and the display formatter can never disagree about scale.
  ({int patientShare, int insurerPaid, int projectedImpact}) get _preview {
    final probe = MedicalBill()
      ..billedAmount = _amountMinor
      ..patientSharePercent = _patientSharePercent
      ..paymentMethod = _paymentMethod
      ..state = _state;
    return (
      patientShare: probe.patientShareAmount,
      insurerPaid: probe.insurerPaidAmount,
      projectedImpact: probe.fundsImpact,
    );
  }

  // -----------------------------------------------------------------------------
  // Save (T016)
  // -----------------------------------------------------------------------------

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;

    final billContext = ref.read(medicalBillContextProvider);
    if (billContext == null) {
      _toast('Set up a monthly budget first so this bill can affect it.');
      return;
    }
    final profileId = ref.read(activeProfileProvider).value?.id;
    if (profileId == null) {
      _toast('No active profile. Create one to save medical bills.');
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(medicalRepositoryProvider);
    final navigator = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // FR-008: typing a new provider name adds it to the directory.
      var providerId = _selectedProviderId;
      final typedProvider = _providerNameController.text.trim();
      if (providerId == null && typedProvider.isNotEmpty) {
        final provider = await repo.findOrCreateProvider(
          profileId: profileId,
          name: typedProvider,
        );
        providerId = provider.id;
      }

      var memberId = _selectedFamilyMemberId;
      final typedMember = _memberNameController.text.trim();
      if (memberId == null && typedMember.isNotEmpty) {
        final member = await repo.saveFamilyMember(
          profileId: profileId,
          name: typedMember,
          relation: 'Family',
        );
        memberId = member.id;
      }

      final bill = widget.existingBill ?? MedicalBill();
      bill
        ..billedAmount = _amountMinor
        ..patientSharePercent = _patientSharePercent
        ..paymentMethod = _paymentMethod
        ..serviceTypeId = _serviceTypeId
        ..providerId = providerId
        ..familyMemberId = memberId
        ..billPhotoPath = _billPhotoPath
        ..insurerReplyPath = _insurerReplyPath
        ..serviceDate = _serviceDate
        ..profileId = profileId
        ..currency = _currencyCode.code
        ..state = _state;

      // FR-055: an explicit month override wins over the service month.
      final override = _monthOverride?.trim();
      if (override != null && override.isNotEmpty) {
        bill.yearMonth = override;
      }

      final saved = await repo.saveBill(
        bill,
        billContext,
        status: _state == MedicalBillState.planned
            ? ExpenseStatus.planned
            : ExpenseStatus.paid,
      );

      // FR-034: editing a reimbursed bill corrects the payout rather than
      // stacking a second one.
      if (saved.reimbursedAmount > 0) {
        final amount = double.tryParse(_reimbursementController.text.trim());
        if (amount != null && amount > 0) {
          final code = saved.currencyCode ?? _currencyCode;
          final amountMinor = Money.fromMajor(amount, code).minorUnits;
          if (amountMinor != saved.reimbursedAmount) {
            await repo.logReimbursement(saved, amount: amountMinor);
          }
        }
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            _isEditing ? 'Medical bill updated ✅' : 'Medical bill saved ✅',
          ),
        ));
      if (navigator.canPop()) {
        navigator.pop();
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } on ArgumentError catch (error) {
      if (!mounted) return;
      _toast(error.message?.toString() ?? 'Check the values you entered.');
    } catch (error) {
      if (!mounted) return;
      _toast('Could not save the bill: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked == null) return;
    setState(() => _serviceDate = picked);
  }

  /// Adopts the profile's default patient share once it resolves.
  void _prefillPatientShare(InsuranceProfile? profile) {
    if (_isEditing || profile == null) return;
    final percent = profile.defaultPatientPercent;
    if (percent <= 0) return;
    final next = percent.toStringAsFixed(0);
    if (_patientShareController.text != next) {
      _patientShareController.text = next;
      setState(() {});
    }
  }

  // -----------------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Adopt the profile's default patient share once it resolves.
    ref.listen<AsyncValue<InsuranceProfile?>>(insuranceProfileProvider,
        (_, next) => _prefillPatientShare(next.value));

    final background = MedicalTheme.background(context);
    final providers = ref.watch(medicalProvidersProvider).value ?? const [];
    final members = ref.watch(familyMembersProvider).value ?? const [];
    final serviceTypes = ref.watch(selectableServiceTypesProvider);
    final allServiceTypes = ref.watch(medicalServiceTypesProvider).value ??
        const <MedicalServiceType>[];
    final selectedTypeMissing = _serviceTypeId != null &&
        !serviceTypes.any((t) => t.id == _serviceTypeId);
    String? selectedTypeName;
    if (selectedTypeMissing) {
      for (final type in allServiceTypes) {
        if (type.id == _serviceTypeId) {
          selectedTypeName = type.name;
          break;
        }
      }
    }
    final estimate = _preview;
    final showReimbursement = _showReimbursementField;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Medical Bill' : 'Add Medical Bill'),
        backgroundColor: background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _saving ? null : _saveBill,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProviderSelector(
              providers: providers,
              selectedId: _selectedProviderId,
              newNameController: _providerNameController,
              onChanged: (value) => setState(() {
                if (value == _newProviderSentinel) {
                  _selectedProviderId = null;
                } else {
                  _selectedProviderId = value as int?;
                  _providerNameController.clear();
                }
              }),
            ),
            const SizedBox(height: 16),
            _MemberSelector(
              members: members,
              selectedId: _selectedFamilyMemberId,
              newNameController: _memberNameController,
              onChanged: (value) => setState(() {
                if (value == _newMemberSentinel) {
                  _selectedFamilyMemberId = null;
                } else {
                  _selectedFamilyMemberId = value as int?;
                  _memberNameController.clear();
                }
              }),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Billed amount',
                      prefixText: '${_currencyCode.symbol} ',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final parsed = double.tryParse(value?.trim() ?? '');
                      if (parsed == null) return 'Enter the billed amount';
                      if (parsed <= 0) return 'Must be greater than zero';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<CurrencyCode>(
                    key: const Key('currencyCodeField'),
                    initialValue: _currencyCode,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: CurrencyCode.values.map((code) {
                      return DropdownMenuItem(
                        value: code,
                        child: Text(code.code.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // FR-041: the single most consequential choice on this form.
            DropdownButtonFormField<MedicalPaymentMethod>(
              key: const Key('paymentMethodField'),
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'How was this paid?',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final method in MedicalPaymentMethod.values)
                  DropdownMenuItem(
                    value: method,
                    child: Text(
                      method == MedicalPaymentMethod.insurerPaid
                          ? 'Insurer paid (you pay your share only)'
                          : 'Self-paid (you pay in full, then claim back)',
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _paymentMethod = value;
                  // D2: an insurer reply cannot survive the switch to
                  // insurer-paid, so drop it rather than save an invalid pair.
                  if (value == MedicalPaymentMethod.insurerPaid) {
                    _insurerReplyPath = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('patientShareField'),
              controller: _patientShareController,
              decoration: const InputDecoration(
                labelText: 'Your share (%)',
                helperText: 'The percentage you pay, not the insurer\'s.',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final parsed = double.tryParse(value?.trim() ?? '');
                if (parsed == null) return 'Enter your share';
                if (parsed < 0 || parsed > 100) {
                  return 'Must be between 0 and 100';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              key: const Key('serviceTypeField'),
              initialValue: _serviceTypeId,
              decoration: const InputDecoration(
                labelText: 'Service type',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('None')),
                // An archived (or not-yet-loaded) type must still be shown so
                // the seeded `initialValue` always has exactly one matching
                // item — otherwise DropdownButtonFormField asserts on frame 1
                // of the Edit form (defect batch walkthrough).
                if (selectedTypeMissing)
                  DropdownMenuItem<int?>(
                    value: _serviceTypeId,
                    enabled: false,
                    child: Text(selectedTypeName ?? 'Service type'),
                  ),
                for (final type in serviceTypes)
                  DropdownMenuItem<int?>(
                      value: type.id, child: Text(type.name)),
              ],
              onChanged: (value) => setState(() => _serviceTypeId = value),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Service date'),
              subtitle: Text(DateFormat.yMMMd().format(_serviceDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickServiceDate,
            ),
            ListTile(
              key: const Key('monthOverrideTile'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Belongs to month'),
              subtitle: Text(
                (_monthOverride ?? '').isNotEmpty
                    ? _monthOverride!
                    : DateFormat.yMMM().format(_serviceDate),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickMonthOverride,
            ),
            const SizedBox(height: 8),
            // FR-052: the state drives both the insurance meaning and the cost.
            SegmentedButton<MedicalBillState>(
              key: const Key('billStateField'),
              segments: const [
                ButtonSegment(
                  value: MedicalBillState.planned,
                  label: Text('Planned'),
                ),
                ButtonSegment(
                  value: MedicalBillState.waiting,
                  label: Text('Waiting'),
                ),
                ButtonSegment(
                  value: MedicalBillState.paid,
                  label: Text('Paid'),
                ),
              ],
              selected: {_state},
              onSelectionChanged: (selection) =>
                  setState(() => _state = selection.first),
            ),
            const SizedBox(height: 8),
            _EstimateCard(
              currency: _currencyCode,
              patientShare: estimate.patientShare,
              insurerPaid: estimate.insurerPaid,
              projectedImpact: estimate.projectedImpact,
              paymentMethod: _paymentMethod,
            ),
            if (showReimbursement) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _reimbursementController,
                decoration: const InputDecoration(
                  labelText: 'Reimbursed amount',
                  border: OutlineInputBorder(),
                  helperText:
                      'Already reimbursed - edit to correct the payout.',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  // 0 is a valid "not reimbursed yet" state on a self-paid
                  // bill; without this the Edit form could never save one.
                  if (parsed == null || parsed < 0) return 'Enter an amount';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            // FR-047: the two documents are separate, and the insurer reply is
            // self-paid only.
            _DocumentTile(
              documentKey: const Key('billPhotoTile'),
              label: 'Bill photo',
              path: _billPhotoPath,
              helper: 'Optional. Keep it for your own records.',
              onPickCamera: () => _pickImage(ImageSource.camera),
              onPickGallery: () => _pickImage(ImageSource.gallery),
              onClear: () => setState(() => _billPhotoPath = null),
            ),
            if (_paymentMethod == MedicalPaymentMethod.selfPaid)
              _DocumentTile(
                documentKey: const Key('insurerReplyTile'),
                label: 'Insurer reply',
                path: _insurerReplyPath,
                helper: 'Optional. Needed to claim a self-paid bill back.',
                onPickDocument: _pickInsurerReply,
                onClear: () => setState(() => _insurerReplyPath = null),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _saveBill,
              child: Text(_isEditing ? 'Save Changes' : 'Save Bill'),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Provider + patient selection (T011)
// -----------------------------------------------------------------------------

class _ProviderSelector extends StatefulWidget {
  const _ProviderSelector({
    required this.providers,
    required this.selectedId,
    required this.newNameController,
    required this.onChanged,
  });

  final List<MedicalProvider> providers;
  final int? selectedId;
  final TextEditingController newNameController;
  final ValueChanged<Object?> onChanged;

  @override
  State<_ProviderSelector> createState() => _ProviderSelectorState();
}

class _ProviderSelectorState extends State<_ProviderSelector> {
  @override
  Widget build(BuildContext context) {
    final typingNew = widget.selectedId == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<Object>(
          key: ValueKey(
            'provider-${widget.selectedId}-${typingNew ? widget.newNameController.text : ''}',
          ),
          initialValue: typingNew ? null : widget.selectedId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Medical provider',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final provider in widget.providers)
              DropdownMenuItem<Object>(
                value: provider.id,
                child: Text(
                  provider.specialty == null
                      ? provider.name
                      : '${provider.name} · ${provider.specialty}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const DropdownMenuItem<Object>(
              value: _newProviderSentinel,
              child: Text('+ Add a new provider'),
            ),
          ],
          onChanged: widget.onChanged,
        ),
        if (typingNew) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.newNameController,
            decoration: const InputDecoration(
              labelText: 'Provider name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_hospital_outlined),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ],
    );
  }
}

class _MemberSelector extends StatefulWidget {
  const _MemberSelector({
    required this.members,
    required this.selectedId,
    required this.newNameController,
    required this.onChanged,
  });

  final List<FamilyMember> members;
  final int? selectedId;
  final TextEditingController newNameController;
  final ValueChanged<Object?> onChanged;

  @override
  State<_MemberSelector> createState() => _MemberSelectorState();
}

class _MemberSelectorState extends State<_MemberSelector> {
  @override
  Widget build(BuildContext context) {
    final typingNew = widget.selectedId == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<Object>(
          key: ValueKey(
            'member-${widget.selectedId}-${typingNew ? widget.newNameController.text : ''}',
          ),
          initialValue: typingNew ? null : widget.selectedId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Patient',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final member in widget.members)
              DropdownMenuItem<Object>(
                value: member.id,
                child: Text(
                  member.relation.isEmpty
                      ? member.name
                      : '${member.name} · ${member.relation}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const DropdownMenuItem<Object>(
              value: _newMemberSentinel,
              child: Text('+ Add a new family member'),
            ),
          ],
          onChanged: widget.onChanged,
        ),
        if (typingNew) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.newNameController,
            decoration: const InputDecoration(
              labelText: 'Patient name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Patient-share estimate + documents
// -----------------------------------------------------------------------------

/// Live preview of who pays what, and - most importantly - what this bill will
/// actually take out of the budget once saved.
///
/// The impact figure comes from [MedicalBill.fundsImpact] rather than local
/// arithmetic, so the preview cannot drift from what gets stored (R07).
class _EstimateCard extends StatelessWidget {
  const _EstimateCard({
    required this.currency,
    required this.patientShare,
    required this.insurerPaid,
    required this.projectedImpact,
    required this.paymentMethod,
  });

  final CurrencyCode currency;
  final int patientShare;
  final int insurerPaid;

  /// What this bill removes from available funds, per the money-impact table.
  final int projectedImpact;

  final MedicalPaymentMethod paymentMethod;

  @override
  Widget build(BuildContext context) {
    final insurerPaidBill = paymentMethod == MedicalPaymentMethod.insurerPaid;
    return Card(
      color: MedicalTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who pays what',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _AmountRow(
              label: 'You pay',
              value: MedicalTheme.moneyMinor(currency, patientShare),
              color: Colors.orange,
            ),
            _AmountRow(
              label: 'Insurer pays',
              value: MedicalTheme.moneyMinor(currency, insurerPaid),
              color: Colors.green,
            ),
            const Divider(height: 24),
            _AmountRow(
              label: insurerPaidBill
                  ? 'Leaves your budget (your share)'
                  : 'Leaves your budget (full charge)',
              value: MedicalTheme.moneyMinor(currency, projectedImpact),
              color: Colors.red,
              bold: true,
            ),
            const SizedBox(height: 8),
            Text(
              insurerPaidBill
                  ? 'The insurer is billed directly, so only your share affects '
                      'this month. There is nothing to claim back.'
                  : 'You paid in full, so the whole charge leaves your budget '
                      'until a reimbursement is recorded.',
              style: TextStyle(
                fontSize: 12,
                color: MedicalTheme.subtleText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium;
    final style = base?.copyWith(
      fontWeight: bold ? FontWeight.bold : FontWeight.w600,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: base),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// One optional document with its own pickers (FR-047).
///
/// Split from the old single attachment list because the two documents carry
/// different rules: the bill photo is free for either payment method, the
/// insurer reply belongs only on a self-paid bill.
class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.documentKey,
    required this.label,
    required this.path,
    required this.helper,
    required this.onClear,
    this.onPickCamera,
    this.onPickGallery,
    this.onPickDocument,
  });

  final Key documentKey;
  final String label;
  final String? path;
  final String helper;
  final VoidCallback onClear;
  final VoidCallback? onPickCamera;
  final VoidCallback? onPickGallery;
  final VoidCallback? onPickDocument;

  @override
  Widget build(BuildContext context) {
    final attached = path != null && path!.isNotEmpty;
    return Card(
      key: documentKey,
      color: MedicalTheme.surface(context),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          attached ? Icons.description : Icons.description_outlined,
        ),
        title: Text(label),
        subtitle: Text(
          attached ? path! : helper,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: attached
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Remove',
                onPressed: onClear,
              )
            : const Icon(Icons.add_photo_alternate_outlined),
        onTap: attached
            ? null
            : () {
                if (onPickDocument != null) {
                  onPickDocument!();
                } else if (onPickCamera != null) {
                  onPickCamera!();
                }
              },
      ),
    );
  }
}
