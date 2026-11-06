import 'medical_messages.dart' show medicalReceiptMessage;
import 'medical_access_check.dart';
import 'medical_bill_review_dialog.dart';
import 'medical_collapsible_section.dart';
import 'reminder_picker_sheet.dart';
import '../../../core/services/medical_bill_basis.dart';
import '../../../core/services/medical_receipt_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../shared/presentation/modals/app_dialog.dart';
import '../../../shared/presentation/modals/app_sheet.dart';
import '../../../shared/presentation/modals/app_date_picker.dart';
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
import '../../../core/providers/active_space_provider.dart';
import '../../../shared/presentation/confirm_space_on_save.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/money_field.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/medical_providers.dart';
import 'medical_theme.dart';
import 'medical_copy.dart';

/// Add / edit form for a single [MedicalBill] (T010).
///
/// Passing [existingBill] switches the form into edit mode; the linked expense
/// is updated in place so the engine's budget math stays consistent.
class MedicalBillForm extends ConsumerStatefulWidget {
  const MedicalBillForm({
    super.key,
    this.existingBill,
  });

  final MedicalBill? existingBill;

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
        return MedicalBillForm(existingBill: bill);
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

  int? _selectedProviderId;
  int? _selectedFamilyMemberId;
  int? _serviceTypeId;

  /// Entries created inline in this form, kept locally so they are selectable
  /// immediately even before the directory stream refreshes.
  final List<MedicalProvider> _createdProviders = [];
  final List<FamilyMember> _createdMembers = [];
  final List<MedicalServiceType> _createdServiceTypes = [];

  /// FR-041: the only two methods. Changes what the bill costs the budget.
  MedicalPaymentMethod _paymentMethod = MedicalPaymentMethod.selfPaid;

  /// The bill document. Optional either way (FR-047).
  String? _billPhotoPath;

  /// The insurer's reply. Edit only: new bills never attach one (PRD §12.2).
  String? _insurerReplyPath;

  DateTime _serviceDate = DateTime.now();
  DateTime? _followUpDate;

  /// The month whose budget the bill affects. Always explicit and preserved,
  /// even for historical bills (PRD §6.2, AC-13).
  DateTime _budgetPeriod = DateTime(DateTime.now().year, DateTime.now().month);
  bool _budgetPeriodTouched = false;

  /// Creation always opens `planned`; editing keeps the stored lifecycle state
  /// because payment and status changes live in Bill Management (D2).
  MedicalBillState _state = MedicalBillState.planned;

  CurrencyCode? _selectedCurrency;

  /// The coverage field is a percentage — select-all-on-focus but no grouping.
  late final FocusNode _coverageFocus;

  bool _saving = false;
  bool _confirmingSave = false;
  bool _coverageEdited = false;
  bool _coverageDefaultApplied = false;
  String? _saveError;
  bool get _personal => widget.existingBill != null
      ? widget.existingBill!.sharedSpaceId == null
      : ref.read(activeSpaceIdProvider) == null;

  bool get _isEditing => widget.existingBill != null;

  /// A finished bill is terminal: its state and payment method are frozen, so
  /// the form mirrors the detail screen's lock when opened on such a bill.
  bool get _isLocked => widget.existingBill?.state == MedicalBillState.finished;

  @override
  void initState() {
    super.initState();
    _coverageFocus = selectAllOnFocus(_coverageController);
    if (widget.existingBill == null) {
      _state = MedicalBillState.planned;
      _followUpDate = _defaultReminder();
      _coverageController.text = _formatPercent(_defaultCoverage());
      _budgetPeriod = DateTime(DateTime.now().year, DateTime.now().month);
      return;
    }
    final bill = widget.existingBill!;
    _amountController.text = NumberFormat('#,##0.00', 'en_US').format(
      Money(bill.billedAmount, bill.currencyCode ?? CurrencyCode.huf)
          .majorValue,
    );
    _coverageController.text = _formatPercent(bill.insuranceCoveragePercent);
    _selectedProviderId = bill.providerId;
    _selectedFamilyMemberId = bill.familyMemberId;
    _serviceTypeId = bill.serviceTypeId;
    _paymentMethod = bill.paymentMethod;
    _billPhotoPath = bill.billPhotoPath;
    _insurerReplyPath = bill.insurerReplyPath;
    _serviceDate = bill.serviceDate ?? DateTime.now();
    _followUpDate = bill.followUpDate;
    _state = bill.state;
    _budgetPeriod = _periodFromMonth(bill.yearMonth) ??
        DateTime(_serviceDate.year, _serviceDate.month);
    _selectedCurrency = bill.currencyCode;
  }

  /// The profile's default coverage, or 80% when none is configured.
  double _defaultCoverage() {
    final preset = ref.read(insuranceProfileProvider).valueOrNull;
    final share = preset?.defaultPatientPercent;
    if (share != null && share.isFinite && share >= 0 && share <= 100) {
      return 100 - share;
    }
    return 80;
  }

  static String _formatPercent(double value) =>
      value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);

  static DateTime? _periodFromMonth(String yearMonth) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(yearMonth);
    if (match == null) return null;
    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    if (year == null || month == null || month < 1 || month > 12) return null;
    return DateTime(year, month);
  }

  /// Creation default: three days from today, at 09:00 local (PRD §7.1).
  static DateTime _defaultReminder() {
    final target = DateTime.now().add(const Duration(days: 3));
    return DateTime(target.year, target.month, target.day, 9);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _coverageController.dispose();
    _coverageFocus.dispose();
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

  /// Picks the bill document from the device file manager (PRD §12.1).
  Future<void> _pickBillFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic'],
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

  Future<void> _pickReminder() async {
    final picked = await ReminderPickerSheet.show(
      context,
      initialDate: _followUpDate,
      allowClear: true,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _followUpDate = picked == ReminderPickerSheet.cleared ? null : picked;
    });
  }

  /// Choose the month + year the bill belongs to, including historical years.
  Future<void> _pickBudgetPeriod() async {
    final picked = await showAppDialog<DateTime>(
      context: context,
      builder: (dialog) => _BudgetPeriodDialog(initial: _budgetPeriod),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _budgetPeriod = DateTime(picked.year, picked.month);
      _budgetPeriodTouched = true;
    });
  }

  // -----------------------------------------------------------------------------
  // Derived values (T013)
  // -----------------------------------------------------------------------------

  double get _amount {
    final value = parseMoneyInput(_amountController.text);
    return value != null && value.isFinite && value > 0 ? value : 0;
  }

  CurrencyCode get _currencyCode {
    if (_selectedCurrency != null) return _selectedCurrency!;
    final primary = ref.read(medicalBillContextProvider)?.primaryCurrency;
    return CurrencyCode.tryParse(primary ?? '') ?? CurrencyCode.huf;
  }

  int get _amountMinor => Money.fromMajor(_amount, _currencyCode).minorUnits;

  /// Coverage as entered, or `null` when the input is invalid.
  double? get _coveragePercent {
    final value = double.tryParse(_coverageController.text.trim());
    return value != null && value.isFinite && value >= 0 && value <= 100
        ? value
        : null;
  }

  /// FR-048 / PRD §8.3: the share the user pays, derived from coverage.
  double get _patientSharePercent => 100 - (_coveragePercent ?? 0);

  /// New bills are always planned; editing keeps the stored lifecycle status.
  ExpenseStatus get _draftExpenseStatus => _state == MedicalBillState.planned
      ? ExpenseStatus.planned
      : ExpenseStatus.paid;

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
      // Creation only plans the bill; the effect is what will count once the
      // relevant payment is confirmed (PRD §17.2).
      projectedImpact: probe.plannedBudgetEffect,
    );
  }

  // -----------------------------------------------------------------------------
  // Save (T016)
  // -----------------------------------------------------------------------------

  /// Serialize the whole save, including confirmations and directory creation.
  Future<void> _saveBill() async {
    if (_saving || _confirmingSave) return;
    setState(() => _confirmingSave = true);
    try {
      await _saveBillImpl();
    } finally {
      if (mounted) setState(() => _confirmingSave = false);
    }
  }

  Future<void> _saveBillImpl() async {
    final validFields = _formKey.currentState!.validate();
    final coverage = _coveragePercent;
    // Lazy sections may be outside the widget tree while saving. Validate the
    // actual draft as well so invalid input cannot become the preview's zero.
    if (!validFields || _amount <= 0 || coverage == null) {
      setState(() => _saveError = _amount <= 0
          ? 'Enter a bill total greater than zero.'
          : coverage == null
              ? 'Insurance coverage must be between 0 and 100.'
              : 'Select a patient, a provider and a service type before saving.');
      return;
    }
    if (!_isEditing &&
        (_selectedProviderId == null ||
            _selectedFamilyMemberId == null ||
            _serviceTypeId == null)) {
      setState(() => _saveError =
          'Select a patient, a provider and a service type before saving.');
      return;
    }
    if (_saving) return;

    final access = medicalAccessCheck(context, ref);
    if (!access()) return;
    var replyForSave = _insurerReplyPath;
    if (_paymentMethod == MedicalPaymentMethod.insurerPaid &&
        replyForSave != null) {
      final remove = await showAppDialog<bool>(
          context: context,
          builder: (dialog) => AppDialog(
                title: const Text('Remove insurance reply?'),
                content: const Text(
                    'This document belongs to a bill you pay yourself. Keep editing to change the payment choice, or remove the reply from this bill and save. The file itself is not deleted.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Keep editing')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: const Text('Remove reply and save'))
                ],
              ));
      if (remove != true || !mounted || !access()) return;
      replyForSave = null;
    }
    final billContext = ref.read(medicalBillContextProvider);
    if (billContext == null) {
      _toast('Set up a monthly budget first so this bill can affect it.');
      return;
    }
    if (ref.read(activeProfileProvider).value?.id == null) {
      _toast('No active profile. Create one to save medical bills.');
      return;
    }

    // US6 (T055): a save into a shared space is confirmed first, naming the
    // space, unless the user turned the guard off in Settings.
    if (billContext.sharedSpaceId != null &&
        ref.read(confirmSharedSaveOnProvider)) {
      final spaceName =
          ref.read(activeSpaceProvider).value?.name ?? 'this space';
      final decision = await confirmSpaceOnSave(
        context,
        title: 'Medical bill',
        amountText: formatMoney(Money(_amountMinor, _currencyCode)),
        spaceName: spaceName,
      );
      if (!mounted) return;
      if (decision != SpaceSaveDecision.confirm) {
        // "Change context" (or a dismissal) abandons this save and returns to
        // the shell, where the top switcher is visible.
        if (decision == SpaceSaveDecision.changeContext) context.pop();
        return;
      }
    }

    setState(() {
      _saving = true;
      _saveError = null;
    });
    final repo = ref.read(medicalRepositoryProvider);
    final navigator = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final history = _personal && widget.existingBill != null
          ? await repo.receiptHistory(widget.existingBill!.id,
              isAccessCurrent: access)
          : null;
      if (history?.approval != null &&
          (_createdProviders.isNotEmpty ||
              _createdMembers.isNotEmpty ||
              _createdServiceTypes.isNotEmpty)) {
        // Directory rows written inline must not become part of an approved
        // bill correction; the correction flow requires a stable directory.
        throw const MedicalReceiptException('directoryBeforeCorrection');
      }

      final bill = widget.existingBill == null
          ? MedicalBill()
          : copyMedicalBill(widget.existingBill!);
      bill
        ..billedAmount = _amountMinor
        ..patientSharePercent = _patientSharePercent
        ..paymentMethod = _paymentMethod
        ..serviceTypeId = _serviceTypeId
        ..providerId = _selectedProviderId
        ..familyMemberId = _selectedFamilyMemberId
        ..billPhotoPath = _billPhotoPath
        ..insurerReplyPath = replyForSave
        ..serviceDate = _serviceDate
        ..followUpDate = _followUpDate
        // FR-013: the context owns the row, so a shared bill is keyed on the
        // space (`billContext.profileId` is 0 for a space) and can never be
        // pinned to a personal profile.
        ..profileId = billContext.profileId
        ..currency = _currencyCode.code
        ..state = _state;
      if (!_isEditing) {
        bill
          ..overallStatus = MedicalOverallStatus.open
          ..providerPaymentStatus =
              _paymentMethod == MedicalPaymentMethod.insurerPaid
                  ? MedicalProviderPaymentStatus.notRequired
                  : MedicalProviderPaymentStatus.notConfirmed
          ..insuranceRequestStatus = MedicalInsuranceRequestStatus.notSubmitted
          ..salarySettlementType =
              _paymentMethod == MedicalPaymentMethod.insurerPaid
                  ? MedicalSalarySettlementType.userShareDeduction
                  : MedicalSalarySettlementType.insuranceRefund
          ..salarySettlementStatus = MedicalSalarySettlementStatus.notRequired
          ..needsReview = false;
      }
      bill.lastUpdatedAt = DateTime.now();

      // PRD §6.2: the explicitly chosen period (including a historical one) is
      // stored as-is; it is never replaced by the current month.
      bill.yearMonth = DateFormat('yyyy-MM').format(_budgetPeriod);

      var status = history?.expense.status ?? _draftExpenseStatus;
      MedicalBill saved;
      if (history?.approval != null &&
          (medicalBillBasis(history!.bill) != medicalBillBasis(bill) ||
              status != history.expense.status ||
              bill.state != history.bill.state)) {
        if (!mounted || !access()) return;
        final reason = await medicalReviewReason(
            context, 'Review approved bill correction',
            isAccessCurrent: access);
        if (reason == null || !mounted || !access()) return;
        final preview = await repo.reviewBill(
            proposed: bill,
            status: status,
            reason: reason,
            isAccessCurrent: access);
        if (!mounted ||
            !access() ||
            !await confirmMedicalBillReview(context, preview,
                isAccessCurrent: access,
                directory: ref.read(medicalDirectoryProvider),
                services: {
                  for (final service
                      in ref.read(medicalServiceTypesProvider).valueOrNull ??
                          const <MedicalServiceType>[])
                    service.id: service.name
                })) {
          return;
        }
        await repo.applyBillReview(
            review: preview,
            operationKey: DateTime.now().microsecondsSinceEpoch.toString(),
            isAccessCurrent: access);
        saved = preview.proposed;
      } else {
        saved = await repo.saveBill(bill, billContext,
            status: status, isAccessCurrent: access);
      }

      // Reminder is metadata only; scheduling happens after the bill is saved so
      // a notification failure cannot roll back booked money.
      if (_followUpDate != widget.existingBill?.followUpDate) {
        try {
          await repo.setFollowUpDate(saved, _followUpDate,
              isAccessCurrent: access);
        } catch (_) {
          if (mounted) {
            _toast('Bill saved, but the reminder could not be scheduled.');
          }
        }
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            _isEditing
                ? 'Bill updated.'
                : 'Bill saved as planned. Record payments and insurance '
                    'replies in bill details.',
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
      setState(() => _saveError = error is MedicalReceiptException
          ? medicalReceiptMessage(error)
          : 'Could not save the bill: $error');
      _toast(_saveError!);
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
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(DateTime.now().year - 20),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked == null) return;
    setState(() {
      _serviceDate = picked;
      // Suggest the matching period, but never lock it (PRD §6.2).
      if (!_budgetPeriodTouched) {
        _budgetPeriod = DateTime(picked.year, picked.month);
      }
    });
  }

  /// Adopts the profile's default coverage once it resolves.
  void _prefillCoverage(InsuranceProfile? profile) {
    if (_isEditing ||
        profile == null ||
        _coverageEdited ||
        _coverageDefaultApplied) {
      return;
    }
    final share = profile.defaultPatientPercent;
    if (!share.isFinite || share < 0 || share > 100) return;
    _coverageDefaultApplied = true;
    final next = _formatPercent(100 - share);
    if (_coverageController.text != next) {
      _coverageController.text = next;
      setState(() {});
    }
  }

  // -----------------------------------------------------------------------------
  // Inline directory creation (PRD §5.1–5.3)
  // -----------------------------------------------------------------------------

  /// Asks for a name and trims it; `null` means the user cancelled.
  Future<String?> _askDirectoryName({
    required String title,
    required String label,
  }) {
    return showAppDialog<String>(
      context: context,
      builder: (dialog) => _NameDialog(title: title, label: label),
    );
  }

  ({int profileId, int? sharedSpaceId})? get _directoryContext {
    final profileId = ref.read(activeProfileProvider).value?.id;
    final billContext = ref.read(medicalBillContextProvider);
    if (profileId == null) return null;
    return (profileId: profileId, sharedSpaceId: billContext?.sharedSpaceId);
  }

  Future<void> _addProvider() async {
    final name =
        await _askDirectoryName(title: 'Add provider', label: 'Provider name');
    if (name == null || !mounted) return;
    final contextInfo = _directoryContext;
    if (contextInfo == null) {
      _toast('No active profile. Create one to add providers.');
      return;
    }
    try {
      final provider =
          await ref.read(medicalRepositoryProvider).findOrCreateProvider(
                profileId: contextInfo.profileId,
                sharedSpaceId: contextInfo.sharedSpaceId,
                name: name,
              );
      if (!mounted) return;
      setState(() {
        if (!_createdProviders.any((p) => p.id == provider.id)) {
          _createdProviders.add(provider);
        }
        _selectedProviderId = provider.id;
      });
    } catch (error) {
      if (mounted) _toast('Could not add the provider: $error');
    }
  }

  Future<void> _addMember() async {
    final name =
        await _askDirectoryName(title: 'Add patient', label: 'Patient name');
    if (name == null || !mounted) return;
    final contextInfo = _directoryContext;
    if (contextInfo == null) {
      _toast('No active profile. Create one to add patients.');
      return;
    }
    try {
      final member = await ref.read(medicalRepositoryProvider).saveFamilyMember(
            profileId: contextInfo.profileId,
            sharedSpaceId: contextInfo.sharedSpaceId,
            name: name,
            relation: 'Family',
          );
      if (!mounted) return;
      setState(() {
        if (!_createdMembers.any((m) => m.id == member.id)) {
          _createdMembers.add(member);
        }
        _selectedFamilyMemberId = member.id;
      });
    } catch (error) {
      if (mounted) _toast('Could not add the patient: $error');
    }
  }

  Future<void> _addServiceType() async {
    final name = await _askDirectoryName(
        title: 'Add service type', label: 'Service type name');
    if (name == null || !mounted) return;
    final contextInfo = _directoryContext;
    if (contextInfo == null) {
      _toast('No active profile. Create one to add service types.');
      return;
    }
    try {
      final type = await ref.read(medicalRepositoryProvider).saveServiceType(
            profileId: contextInfo.profileId,
            sharedSpaceId: contextInfo.sharedSpaceId,
            name: name,
          );
      if (!mounted) return;
      setState(() {
        if (!_createdServiceTypes.any((t) => t.id == type.id)) {
          _createdServiceTypes.add(type);
        }
        _serviceTypeId = type.id;
      });
    } catch (error) {
      if (mounted) _toast('Could not add the service type: $error');
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
    final watchedProviders =
        ref.watch(medicalProvidersProvider).value ?? const [];
    final watchedMembers = ref.watch(familyMembersProvider).value ?? const [];
    final watchedServiceTypes = ref.watch(selectableServiceTypesProvider);
    final providers = <MedicalProvider>[
      ...watchedProviders,
      for (final created in _createdProviders)
        if (!watchedProviders.any((p) => p.id == created.id)) created,
    ];
    final members = <FamilyMember>[
      ...watchedMembers,
      for (final created in _createdMembers)
        if (!watchedMembers.any((m) => m.id == created.id)) created,
    ];
    final serviceTypes = <MedicalServiceType>[
      ...watchedServiceTypes,
      for (final created in _createdServiceTypes)
        if (!watchedServiceTypes.any((t) => t.id == created.id)) created,
    ];
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
    final selectedProviderMissing = _selectedProviderId != null &&
        !providers.any((p) => p.id == _selectedProviderId);
    final selectedMemberMissing = _selectedFamilyMemberId != null &&
        !members.any((m) => m.id == _selectedFamilyMemberId);
    final estimate = _preview;

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
            onPressed: _saving || _confirmingSave ? null : _saveBill,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _FormIntro(
              isEditing: _isEditing,
              paymentMethod: _paymentMethod,
            ),
            const SizedBox(height: 12),
            // Grouped, collapsible sections (Phase 2d, T080). Bill details is
            // expanded by default because it holds every save-validated
            // field. maintainState keeps each section's field state and
            // widget keys alive while collapsed, so collapsing never loses
            // input or changes save behaviour.
            MedicalCollapsibleSection(
              storageKey: 'medicalFormBillDetails',
              initiallyExpanded: true,
              title: 'Bill details',
              icon: Icons.receipt_long_outlined,
              accent: Theme.of(context).colorScheme.primary,
              children: [
                const Text('Who pays the provider?',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                for (final method in [
                  MedicalPaymentMethod.selfPaid,
                  MedicalPaymentMethod.insurerPaid
                ]) ...[
                  _PaymentMethodCard(
                    key: ValueKey('paymentMethod-${method.name}'),
                    method: method,
                    selected: _paymentMethod == method,
                    enabled: !_isLocked,
                    onTap: () => setState(() {
                      _paymentMethod = method;
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MoneyField(
                      key: const Key('medicalBilledAmountField'),
                      controller: _amountController,
                      label: 'Bill total',
                      prefixText: '${_currencyCode.symbol} ',
                      validator: (value) {
                        final parsed = parseMoneyInput(value ?? '');
                        if (parsed == null || !parsed.isFinite) {
                          return 'Enter the bill total';
                        }
                        if (parsed <= 0) return 'Must be greater than zero';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CurrencyCode>(
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
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('insuranceCoverageField'),
                  controller: _coverageController,
                  focusNode: _coverageFocus,
                  decoration: const InputDecoration(
                    labelText: 'Insurance coverage (%) *',
                    helperText: MedicalCopy.coverageHelp,
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final parsed = double.tryParse(value?.trim() ?? '');
                    if (parsed == null || !parsed.isFinite) {
                      return 'Enter the insurance coverage';
                    }
                    if (parsed < 0 || parsed > 100) {
                      return 'Must be between 0 and 100';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() => _coverageEdited = true),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final preset in const [0, 50, 70, 80, 90, 100])
                      ChoiceChip(
                        key: Key('insuranceCoveragePreset-$preset'),
                        label: Text('$preset%'),
                        selected: _coveragePercent == preset,
                        onSelected: _isLocked
                            ? null
                            : (_) => setState(() {
                                  _coverageController.text = '$preset';
                                  _coverageEdited = true;
                                }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _AmountRow(
                  label: 'Your share',
                  value:
                      '${_formatPercent(_patientSharePercent)}% · ${MedicalTheme.moneyMinor(_currencyCode, estimate.patientShare)}',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
              ],
            ),
            const SizedBox(height: 12),
            MedicalCollapsibleSection(
              storageKey: 'medicalFormProviderPerson',
              title: 'Provider & person',
              icon: Icons.local_hospital_outlined,
              accent: Colors.teal,
              children: [
                KeyedSubtree(
                  key: const Key('providerField'),
                  child: DropdownButtonFormField<int>(
                    key: ValueKey(
                        'provider-$_selectedProviderId-${providers.length}'),
                    initialValue: _selectedProviderId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Provider *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                    ),
                    validator: (value) {
                      if (value == null && !_isEditing) {
                        return 'Select or add a provider';
                      }
                      return null;
                    },
                    items: [
                      if (selectedProviderMissing)
                        DropdownMenuItem<int>(
                          value: _selectedProviderId,
                          enabled: false,
                          child: const Text('Provider'),
                        ),
                      for (final provider in providers)
                        DropdownMenuItem<int>(
                          value: provider.id,
                          child: Text(
                            provider.specialty == null
                                ? provider.name
                                : '${provider.name} · ${provider.specialty}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _isLocked
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _selectedProviderId = value);
                            }
                          },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: const Key('addProviderAction'),
                    onPressed: _isLocked ? null : _addProvider,
                    icon: const Icon(Icons.add),
                    label: const Text('Add new provider'),
                  ),
                ),
                const SizedBox(height: 8),
                KeyedSubtree(
                  key: const Key('serviceTypeField'),
                  child: DropdownButtonFormField<int>(
                    key: ValueKey(
                        'serviceType-$_serviceTypeId-${serviceTypes.length}'),
                    initialValue: _serviceTypeId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Service type *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null && !_isEditing) {
                        return 'Select or add a service type';
                      }
                      return null;
                    },
                    items: [
                      // An archived (or not-yet-loaded) type must still be shown so
                      // the seeded `initialValue` always has exactly one matching
                      // item — otherwise DropdownButtonFormField asserts on frame 1
                      // of the Edit form (defect batch walkthrough).
                      if (selectedTypeMissing)
                        DropdownMenuItem<int>(
                          value: _serviceTypeId,
                          enabled: false,
                          child: Text(selectedTypeName ?? 'Service type'),
                        ),
                      for (final type in serviceTypes)
                        DropdownMenuItem<int>(
                            value: type.id, child: Text(type.name)),
                    ],
                    onChanged: _isLocked
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _serviceTypeId = value);
                            }
                          },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: const Key('addServiceTypeAction'),
                    onPressed: _isLocked ? null : _addServiceType,
                    icon: const Icon(Icons.add),
                    label: const Text('Add new service type'),
                  ),
                ),
                const SizedBox(height: 8),
                KeyedSubtree(
                  key: const Key('patientField'),
                  child: DropdownButtonFormField<int>(
                    key: ValueKey(
                        'member-$_selectedFamilyMemberId-${members.length}'),
                    initialValue: _selectedFamilyMemberId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Patient *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null && !_isEditing) {
                        return 'Select or add a patient';
                      }
                      return null;
                    },
                    items: [
                      if (selectedMemberMissing)
                        DropdownMenuItem<int>(
                          value: _selectedFamilyMemberId,
                          enabled: false,
                          child: const Text('Patient'),
                        ),
                      for (final member in members)
                        DropdownMenuItem<int>(
                          value: member.id,
                          child: Text(
                            member.relation.isEmpty
                                ? member.name
                                : '${member.name} · ${member.relation}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _isLocked
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _selectedFamilyMemberId = value);
                            }
                          },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: const Key('addPatientAction'),
                    onPressed: _isLocked ? null : _addMember,
                    icon: const Icon(Icons.add),
                    label: const Text('Add new patient'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MedicalCollapsibleSection(
              storageKey: 'medicalFormDatesReminders',
              title: 'Dates & reminders',
              icon: Icons.event_outlined,
              accent: MedicalTheme.semantic(context, MedicalTheme.planned),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Service date'),
                  subtitle: Text(DateFormat.yMMMd().format(_serviceDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickServiceDate,
                ),
                ListTile(
                  key: const Key('budgetPeriodField'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Budget period'),
                  subtitle: Text(DateFormat.yMMMM().format(_budgetPeriod)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickBudgetPeriod,
                ),
                ListTile(
                  key: const Key('followUpReminderTile'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Remind me'),
                  subtitle: Text(_followUpDate == null
                      ? 'No reminder'
                      : DateFormat.yMMMd().add_jm().format(_followUpDate!)),
                  trailing: _followUpDate == null
                      ? const Icon(Icons.chevron_right)
                      : IconButton(
                          tooltip: 'Clear reminder',
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _followUpDate = null),
                        ),
                  onTap: _pickReminder,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _EstimateCard(
              currency: _currencyCode,
              billedAmount: _amountMinor,
              coveragePercent: _coveragePercent ?? 0,
              rejected: _state == MedicalBillState.rejected,
              patientShare: estimate.patientShare,
              insurerPaid: estimate.insurerPaid,
              projectedImpact: estimate.projectedImpact,
              paymentMethod: _paymentMethod,
            ),
            const SizedBox(height: 12),
            MedicalCollapsibleSection(
              storageKey: 'medicalFormDocuments',
              title: 'Documents',
              icon: Icons.attach_file,
              accent: Colors.purple,
              children: [
                // FR-047: the two documents are separate, and the insurer reply is
                // self-paid only.
                _DocumentTile(
                  documentKey: const Key('billPhotoTile'),
                  label: 'Bill document',
                  path: _billPhotoPath,
                  helper:
                      'Optional. Take a photo, pick an image or choose a file.',
                  onPickCamera: () => _pickImage(ImageSource.camera),
                  onPickGallery: () => _pickImage(ImageSource.gallery),
                  onPickDocument: _pickBillFile,
                  onClear: () => setState(() => _billPhotoPath = null),
                ),
                // PRD §12.2: creation never shows an Insurance Reply. It stays
                // available when editing an existing self-paid bill.
                if (_isEditing &&
                    _paymentMethod == MedicalPaymentMethod.selfPaid)
                  _DocumentTile(
                    documentKey: const Key('insurerReplyTile'),
                    label: 'Insurance reply',
                    path: _insurerReplyPath,
                    helper: 'Optional. Keep the reply from your insurer.',
                    onPickDocument: _pickInsurerReply,
                    onClear: () => setState(() => _insurerReplyPath = null),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: MedicalTheme.surface(context),
            border: Border(
                top: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.6))),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_saveError!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              FilledButton.icon(
                key: const Key('saveBillButton'),
                onPressed: _saving || _confirmingSave ? null : _saveBill,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MedicalTheme.inputRadius)),
                ),
                icon: const Icon(Icons.save_outlined),
                label: Text(_isEditing ? 'Save Changes' : 'Save Bill',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Patient-share estimate + documents
// -----------------------------------------------------------------------------

/// A friendly, coloured introduction so the add/edit screen has a clear focus.
class _FormIntro extends StatelessWidget {
  const _FormIntro({required this.isEditing, required this.paymentMethod});

  final bool isEditing;
  final MedicalPaymentMethod paymentMethod;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = paymentMethod == MedicalPaymentMethod.insurerPaid
        ? Colors.teal
        : scheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.16),
            scheme.surface.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(MedicalTheme.cardRadius),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isEditing ? Icons.edit_note : Icons.add_card_outlined,
              color: accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit medical bill' : 'New medical bill',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing
                      ? 'Update the recorded facts. Money still moves only through the bill actions.'
                      : 'Plan the cost now, then record payments and insurance results step by step.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: MedicalTheme.subtleText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A selectable payment-model card with its own colour and clear selected state.
class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    super.key,
    required this.method,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final MedicalPaymentMethod method;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = method == MedicalPaymentMethod.insurerPaid
        ? Colors.teal
        : scheme.primary;
    final selfPaid = method == MedicalPaymentMethod.selfPaid;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: selected ? accent.withValues(alpha: 0.1) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected
                ? accent.withValues(alpha: 0.55)
                : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    selfPaid
                        ? Icons.payments_outlined
                        : Icons.account_balance_outlined,
                    color: accent,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selfPaid ? MedicalCopy.selfPay : MedicalCopy.insurerPay,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: selected ? accent : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selfPaid
                            ? 'You pay the full bill, then claim an insurance refund.'
                            : MedicalCopy.insurerPayHelp,
                        style: TextStyle(
                          fontSize: 12,
                          color: MedicalTheme.subtleText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? accent : scheme.outline,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small single-field dialog that owns its controller, so disposal happens
/// after the route transition instead of while the text field is still mounted.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.label});

  final String title;
  final String label;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isNotEmpty) Navigator.pop(context, trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// Month + year picker for the bill's budget period (PRD §6.2).
///
/// Historical years are selectable so old bills can be entered and preserved.
class _BudgetPeriodDialog extends StatefulWidget {
  const _BudgetPeriodDialog({required this.initial});

  final DateTime initial;

  @override
  State<_BudgetPeriodDialog> createState() => _BudgetPeriodDialogState();
}

class _BudgetPeriodDialogState extends State<_BudgetPeriodDialog> {
  late int _month = widget.initial.month;
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = <int>[
      for (var year = currentYear + 1; year >= currentYear - 20; year--) year,
      if (_year > currentYear + 1 || _year < currentYear - 20) _year,
    ];
    return AppDialog(
      title: const Text('Budget period'),
      content: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              key: const Key('budgetPeriodMonth'),
              initialValue: _month,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Month'),
              items: [
                for (var month = 1; month <= 12; month++)
                  DropdownMenuItem(
                    value: month,
                    child:
                        Text(DateFormat.MMMM().format(DateTime(2000, month))),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _month = value);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              key: const Key('budgetPeriodYear'),
              initialValue: _year,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Year'),
              items: [
                for (final year in years)
                  DropdownMenuItem(value: year, child: Text('$year')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _year = value);
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('budgetPeriodConfirm'),
          onPressed: () => Navigator.pop(context, DateTime(_year, _month)),
          child: const Text('Use period'),
        ),
      ],
    );
  }
}

/// Live preview of who pays what, and - most importantly - what this bill will
/// actually take out of the budget once saved.
///
/// The impact figure comes from [MedicalBill.fundsImpact] rather than local
/// arithmetic, so the preview cannot drift from what gets stored (R07).
class _EstimateCard extends StatelessWidget {
  const _EstimateCard({
    required this.currency,
    required this.billedAmount,
    required this.coveragePercent,
    required this.rejected,
    required this.patientShare,
    required this.insurerPaid,
    required this.projectedImpact,
    required this.paymentMethod,
  });

  final CurrencyCode currency;
  final int billedAmount;
  final double coveragePercent;
  final bool rejected;
  final int patientShare;
  final int insurerPaid;

  /// What this bill is expected to take from the budget once payment is
  /// confirmed (PRD §17.2).
  final int projectedImpact;

  final MedicalPaymentMethod paymentMethod;

  @override
  Widget build(BuildContext context) {
    final insurerPaidBill = paymentMethod == MedicalPaymentMethod.insurerPaid;
    final accent =
        insurerPaidBill ? Colors.teal : Theme.of(context).colorScheme.primary;
    final sharePercent = (100 - coveragePercent).clamp(0.0, 100.0).toDouble();
    final rate = _percentLabel(coveragePercent);
    return Card(
      elevation: 0,
      color: accent.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MedicalTheme.cardRadius),
        side: BorderSide(color: accent.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(Icons.calculate_outlined, size: 19, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Bill estimate',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AmountRow(
                label: 'Bill total',
                value: MedicalTheme.moneyMinor(currency, billedAmount),
                color: Theme.of(context).colorScheme.onSurface),
            _AmountRow(
              label: MedicalCopy.insuranceCoverage,
              value: rate,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            _AmountRow(
              key: const Key('yourShareEstimateRow'),
              label: MedicalCopy.yourShare,
              value:
                  '${_percentLabel(sharePercent)} · ${MedicalTheme.moneyMinor(currency, patientShare)}',
              color: Colors.orange,
            ),
            if (!insurerPaidBill)
              _AmountRow(
                key: const Key('expectedRefundRow'),
                label: MedicalCopy.expectedInsuranceRefund,
                value:
                    '$rate · ${MedicalTheme.moneyMinor(currency, rejected ? 0 : insurerPaid)}',
                color: Colors.green,
              )
            else
              _AmountRow(
                key: const Key('insurancePaysProviderRow'),
                label: MedicalCopy.insurancePaysProviderAmount,
                value:
                    '$rate · ${MedicalTheme.moneyMinor(currency, rejected ? 0 : insurerPaid)}',
                color: Colors.green,
              ),
            const Divider(height: 24),
            _AmountRow(
              key: const Key('plannedBudgetEffectRow'),
              label: MedicalCopy.plannedBudgetEffect,
              value: MedicalTheme.moneyMinor(currency, projectedImpact),
              color: Colors.red,
              bold: true,
            ),
            const SizedBox(height: 8),
            Text(
              rejected
                  ? 'Insurance declined. The full bill remains your responsibility. Payment is recorded in bill details.'
                  : insurerPaidBill
                      ? 'Insurance pays its covered share directly to the provider. Only your share is planned for your budget.'
                      : 'You pay the provider in full and expect the covered share back from insurance. The full bill is planned for your budget.',
              style: TextStyle(
                fontSize: 12,
                color: MedicalTheme.subtleText(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              MedicalCopy.creationMovesNoMoney,
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

  static String _percentLabel(double value) => value == value.roundToDouble()
      ? '${value.toStringAsFixed(0)}%'
      : '$value%';
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    super.key,
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
          Expanded(child: Text(label, style: base)),
          const SizedBox(width: 12),
          Flexible(child: Text(value, style: style, textAlign: TextAlign.end)),
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
        onTap: () => _showSourceSheet(context),
      ),
    );
  }

  /// PRD §12.1: camera, gallery and file manager are all offered.
  Future<void> _showSourceSheet(BuildContext context) async {
    final actions = <Widget>[
      if (onPickCamera != null)
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: const Text('Take photo'),
          onTap: () {
            Navigator.pop(context);
            onPickCamera!();
          },
        ),
      if (onPickGallery != null)
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Gallery'),
          onTap: () {
            Navigator.pop(context);
            onPickGallery!();
          },
        ),
      if (onPickDocument != null)
        ListTile(
          leading: const Icon(Icons.folder_open_outlined),
          title: const Text('Choose file'),
          onTap: () {
            Navigator.pop(context);
            onPickDocument!();
          },
        ),
    ];
    if (actions.isEmpty) return;
    await showAppSheet<void>(
      context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
