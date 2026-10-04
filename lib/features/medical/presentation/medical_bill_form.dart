import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
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
  final _coverageController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _reimbursementController = TextEditingController();

  int? _selectedProviderId;
  int? _selectedFamilyMemberId;
  List<String> _attachments = [];
  DateTime _serviceDate = DateTime.now();
  bool _paidToProvider = false;
  bool _saving = false;

  bool get _isEditing => widget.existingBill != null;

  @override
  void initState() {
    super.initState();
    final bill = widget.existingBill;
    if (bill == null) {
      _coverageController.text = '80';
      return;
    }
    _amountController.text = bill.billedAmount.toStringAsFixed(2);
    _coverageController.text = bill.insuranceCoveragePercent.toStringAsFixed(0);
    _selectedProviderId = bill.providerId;
    _selectedFamilyMemberId = bill.familyMemberId;
    _attachments = List<String>.from(bill.attachmentPaths);
    _serviceDate = bill.serviceDate ?? DateTime.now();
    _paidToProvider = widget.initialPaidToProvider;
    _reimbursementController.text = bill.reimbursedAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _coverageController.dispose();
    _providerNameController.dispose();
    _memberNameController.dispose();
    _reimbursementController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------------
  // Attachments (T012)
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
    setState(() {
      if (!_attachments.contains(path)) _attachments.add(path);
    });
  }

  /// Picks any document the insurer sent over, e.g. an EOB PDF.
  Future<void> _pickDocument() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic'],
    );
    final path = file?.path;
    if (path == null || !mounted) return;
    setState(() {
      if (!_attachments.contains(path)) _attachments.add(path);
    });
  }

  // -----------------------------------------------------------------------------
  // Derived values (T013)
  // -----------------------------------------------------------------------------

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0.0;

  double get _coveragePercent =>
      double.tryParse(_coverageController.text.trim()) ?? 0.0;

  /// Live preview of the insurance math while the user types (T013).
  ({double covered, double outOfPocket}) get _estimate {
    final covered = _amount * (_coveragePercent / 100);
    return (
      covered: covered,
      outOfPocket: (_amount - covered).clamp(0.0, double.infinity),
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
        ..billedAmount = _amount
        ..insuranceCoveragePercent = _coveragePercent
        ..providerId = providerId
        ..familyMemberId = memberId
        ..attachmentPaths = List<String>.from(_attachments)
        ..serviceDate = _serviceDate
        ..profileId = profileId;

      final saved = await repo.saveBill(
        bill,
        billContext,
        status: _paidToProvider ? ExpenseStatus.paid : ExpenseStatus.planned,
      );

      // T021: editing an already-reimbursed bill can correct the payout.
      if (saved.claimStatus == ClaimStatus.reimbursed) {
        final amount = double.tryParse(_reimbursementController.text.trim());
        if (amount != null && amount > 0 && amount != saved.reimbursedAmount) {
          await repo.logReimbursement(saved, amount: amount);
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

  void _prefillCoverage(InsuranceProfile? profile) {
    if (_isEditing || profile == null) return;
    final percent = profile.defaultCoveragePercent;
    if (percent <= 0) return;
    final next = percent.toStringAsFixed(0);
    if (_coverageController.text != next) {
      _coverageController.text = next;
    }
  }

  // -----------------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Adopt the profile's default coverage once it resolves.
    ref.listen<AsyncValue<InsuranceProfile?>>(
        insuranceProfileProvider, (_, next) => _prefillCoverage(next.value));

    final background = MedicalTheme.background(context);
    final symbol = ref.watch(medicalCurrencySymbolProvider);
    final providers = ref.watch(medicalProvidersProvider).value ?? const [];
    final members = ref.watch(familyMembersProvider).value ?? const [];
    final estimate = _estimate;
    final showReimbursement =
        widget.existingBill?.claimStatus == ClaimStatus.reimbursed;

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
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Billed amount',
                prefixText: '$symbol ',
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _coverageController,
              decoration: const InputDecoration(
                labelText: 'Insurance coverage (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final parsed = double.tryParse(value?.trim() ?? '');
                if (parsed == null) return 'Enter a coverage percentage';
                if (parsed < 0 || parsed > 100) {
                  return 'Must be between 0 and 100';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _paidToProvider,
              title: const Text('Already paid to provider'),
              subtitle: Text(
                _paidToProvider
                    ? 'Your available budget drops by the full billed amount.'
                    : 'Stays planned — your budget is not affected yet.',
              ),
              onChanged: (value) => setState(() => _paidToProvider = value),
            ),
            const SizedBox(height: 8),
            _EstimateCard(
              currencySymbol: symbol,
              covered: estimate.covered,
              outOfPocket: estimate.outOfPocket,
            ),
            if (showReimbursement) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _reimbursementController,
                decoration: const InputDecoration(
                  labelText: 'Reimbursed amount',
                  border: OutlineInputBorder(),
                  helperText:
                      'Already reimbursed — edit to correct the payout.',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter an amount';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            _AttachmentSection(
              attachments: _attachments,
              onPickCamera: () => _pickImage(ImageSource.camera),
              onPickGallery: () => _pickImage(ImageSource.gallery),
              onPickDocument: _pickDocument,
              onRemove: (path) => setState(() => _attachments.remove(path)),
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
// Insurance estimate + attachments
// -----------------------------------------------------------------------------

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({
    required this.currencySymbol,
    required this.covered,
    required this.outOfPocket,
  });

  final String currencySymbol;
  final double covered;
  final double outOfPocket;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MedicalTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Insurance estimate',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Insurance covers'),
                Text(
                  MedicalTheme.money(currencySymbol, covered),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your estimate'),
                Text(
                  MedicalTheme.money(currencySymbol, outOfPocket),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Deductibles reset yearly, so this counts toward your '
              '${DateTime.now().year} deductible.',
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

class _AttachmentSection extends StatelessWidget {
  const _AttachmentSection({
    required this.attachments,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onPickDocument,
    required this.onRemove,
  });

  final List<String> attachments;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onPickDocument;
  final ValueChanged<String> onRemove;

  static const Map<String, IconData> _icons = {
    'pdf': Icons.picture_as_pdf_outlined,
    'heic': Icons.image_outlined,
    'jpg': Icons.image_outlined,
    'jpeg': Icons.image_outlined,
    'png': Icons.image_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MedicalTheme.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipts & EOBs',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Attach photos or PDFs so you have them at claim time.',
              style: TextStyle(
                fontSize: 12,
                color: MedicalTheme.subtleText(context),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onPickCamera,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Camera'),
                ),
                OutlinedButton.icon(
                  onPressed: onPickGallery,
                  icon: const Icon(Icons.photo_outlined, size: 18),
                  label: const Text('Gallery'),
                ),
                OutlinedButton.icon(
                  onPressed: onPickDocument,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: const Text('File'),
                ),
              ],
            ),
            if (attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final path in attachments)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_iconFor(path)),
                  title: Text(
                    path.split(RegExp(r'[/\\]')).last,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove attachment',
                    onPressed: () => onRemove(path),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(String path) {
    final lower = path.toLowerCase();
    for (final entry in _icons.entries) {
      if (lower.endsWith('.${entry.key}')) return entry.value;
    }
    return Icons.insert_drive_file_outlined;
  }
}
