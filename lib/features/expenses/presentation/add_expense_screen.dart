import 'widgets/expense_metadata_fields.dart';
import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import '../../../core/services/filter_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/confirm_space_on_save.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/profile_identity_color.dart';
import '../../../shared/presentation/widgets/app_card.dart';
import '../../../shared/presentation/widgets/money_field.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../finance/providers/profile_providers.dart';
import '../../finance/repositories/month_finance_repository.dart';
import '../providers/expenses_provider.dart';
import '../providers/category_provider.dart';
import '../domain/expense_date_rules.dart';
import 'expense_destination_guard.dart';
import 'profile_picker_sheet.dart';
import 'widgets/amount_conversion_hint.dart';
import 'widgets/emotion_selector.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  static const _currencies = ['USD', 'EUR', 'HUF', 'CAD'];

  final _metadata = ExpenseMetadataDraft();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  /// Null until the user picks a currency explicitly; the form then defaults to
  /// the profile's main currency (T056) instead of hardcoded USD, so a HUF
  /// expense can never be silently recorded as USD.
  String? _currency;
  String _categoryId = Expense.defaultCategoryId;
  ExpenseStatus _status = ExpenseStatus.paid;
  bool _isReimbursable = false;
  GuiltLevel _guiltLevel = GuiltLevel.essential;

  /// The budget or direct profile the expense is filed under (T141).
  ///
  /// `null` means the Main Profile. It starts as the profile the screen was
  /// opened from — a profile card's "Add expense" button passes it with the
  /// route — and the user can change it with the picker.
  int? _budgetProfileId;
  String? _profileType;
  String? _profileSyncGuid;
  bool _routeRead = false;
  bool _saving = false;
  DateTime? _purchaseDate;

  /// The month that will own the expense. Null means the selected month; a
  /// past (or future planned) date provisions and stores its own month.
  MonthlyBudget? _targetMonth;
  String? _dateError;
  bool _resolvingMonth = false;

  /// True when the combined destination + space dialog already confirmed this
  /// save, so the shared-space prompt does not ask again.
  bool _destinationConfirmed = false;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    // Rebuild on every keystroke so the live conversion hint below the Amount
    // field tracks the input (T056).
    _amountController.addListener(() => setState(() {
          _metadata.evidence.cashConfirmed = false;
        }));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The route may carry the profile the expense belongs to, when the screen
    // was opened from that profile's card (T141). It is read once, here,
    // because the route state is not available in `initState`.
    if (!_routeRead) {
      _routeRead = true;
      final extra = GoRouterState.of(context).extra;
      if (extra is Map && extra['budgetProfileId'] is int) {
        _budgetProfileId = extra['budgetProfileId'] as int;
        _profileType = extra['financialProfileType'] as String? ??
            FinancialProfileType.budget;
      }
    }
  }

  @override
  void dispose() {
    _metadata.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  static double? _parseAmount(String? raw) => parseMoneyInput(raw ?? '');

  /// The currency the form records in: the user's pick, or the profile's main
  /// currency until the user picks (T056).
  String get _effectiveCurrency =>
      _currency ?? ref.read(mainCurrencyProvider).code.toUpperCase();

  Future<void> _pickDate() async {
    final today = _today;
    final first = expenseDateFloor();
    final last = expenseDateCeiling(_status, today);
    // Open the picker in the month being viewed (or in today's month when that
    // is the selected one), not always in the current month.
    final selected = ref.read(selectedYearMonthProvider);
    final parts = selected.split('-').map(int.parse).toList();
    final monthStart = DateTime(parts[0], parts[1], 1);
    final preferred = selected == currentYearMonth(today)
        ? today
        : monthStart.isBefore(first)
            ? first
            : monthStart.isAfter(last)
                ? last
                : monthStart;
    final current = _purchaseDate;
    final initial = current == null
        ? preferred
        : current.isBefore(first)
            ? first
            : current.isAfter(last)
                ? last
                : current;
    final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: first,
        lastDate: last);
    if (picked == null || !mounted) return;
    await _selectDate(picked);
  }

  /// Files the expense into the date's own month. A month that is not on screen
  /// is provisioned first, so a past expense is never written into the selected
  /// month by mistake.
  Future<void> _selectDate(DateTime picked) async {
    final date = DateTime(picked.year, picked.month, picked.day);
    final month = currentYearMonth(date);
    if (month == ref.read(selectedYearMonthProvider)) {
      setState(() {
        _purchaseDate = date;
        _targetMonth = null;
        _dateError = null;
        _metadata.evidence.cashConfirmed = false;
      });
      return;
    }
    setState(() {
      _resolvingMonth = true;
      _dateError = null;
    });
    try {
      final budgetContext = ref.read(budgetContextProvider);
      final repository = ref.read(monthFinanceRepositoryProvider);
      // A brand-new shared space must bring its first month in deliberately;
      // a past expense may not silently create it.
      if (budgetContext.isShared &&
          !await repository.spaceOwnsAnyMonth(budgetContext.spaceId!)) {
        throw StateError(
            'This shared space has no month yet. Bring its first month in before recording this expense.');
      }
      final target = await repository.ensureMonthInContext(
        budgetContext.isShared
            ? ContextRef.shared(
                spaceId: budgetContext.spaceId!, yearMonth: month)
            : ContextRef.personal(
                profileId: budgetContext.profileKey, yearMonth: month),
      );
      if (!mounted) return;
      setState(() {
        _purchaseDate = date;
        _targetMonth = target;
        _metadata.evidence.cashConfirmed = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _purchaseDate = null;
        _targetMonth = null;
        _dateError =
            'That month is not available here. Choose another date or switch the month first.';
      });
      showFinancialFeedback(
          context,
          error is StateError
              ? error.message.toString()
              : 'That month could not be opened for this expense.',
          kind: FinancialFeedbackKind.error);
    } finally {
      if (mounted) setState(() => _resolvingMonth = false);
    }
  }

  Future<void> _saveExpense() async {
    if (_saving || _resolvingMonth || !_formKey.currentState!.validate()) {
      return;
    }
    final date = _purchaseDate;
    if (date == null) {
      setState(() => _dateError = 'Choose the expense date.');
      return;
    }
    if (isFuturePaidExpense(_status, date, DateTime.now())) {
      setState(() => _dateError =
          'A paid expense cannot be dated in the future. Choose Planned or an earlier date.');
      return;
    }
    final destination = _destinationSnapshot();
    final guard = destinationGuardFor(
      isMain: destination.isMain,
      isDirect: destination.isDirect,
      remainingMinor: destination.remainingMinor,
      amountMinorInContext: _expenseAmountInMain(),
      profileName: destination.name,
      profileColor: destination.color,
    );
    if (guard != null) {
      final amount = _parseAmount(_amountController.text) ?? 0.0;
      final code =
          CurrencyCode.tryParse(_effectiveCurrency) ?? CurrencyCode.huf;
      final main = ref.read(mainCurrencyProvider);
      final shared = ref.read(budgetContextProvider).isShared;
      final decision = await confirmExpenseDestination(
        context,
        kind: guard.kind,
        amountText: formatMoney(Money.fromMajor(amount, code)),
        status: _status,
        title: _titleController.text.trim(),
        spaceName: shared
            ? ref.read(activeSpaceProvider).value?.name ?? 'this space'
            : null,
        profileName: guard.profileName,
        profileColor: guard.profileColor,
        remainingText: guard.remainingMinor == null
            ? null
            : formatMinorUnits(guard.remainingMinor!, main),
        borrowText: guard.borrowMinor == null
            ? null
            : formatMinorUnits(guard.borrowMinor!, main),
      );
      if (!mounted) return;
      if (decision == ExpenseDestinationDecision.changeProfile) {
        await _pickProfile();
        return;
      }
      if (decision != ExpenseDestinationDecision.save) return;
      _destinationConfirmed = true;
    }
    setState(() {
      _saving = true;
      _dateError = null;
    });
    try {
      await _saveValidatedExpense();
    } catch (error) {
      if (mounted) {
        showFinancialFeedback(
            context,
            error is StateError
                ? error.message.toString()
                : 'The expense could not be saved. Please try again.',
            kind: FinancialFeedbackKind.error);
      }
    } finally {
      _destinationConfirmed = false;
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveValidatedExpense() async {
    final amount = _parseAmount(_amountController.text) ?? 0.0;
    final budgetContext = ref.read(budgetContextProvider);
    final active = ref.read(activeBudgetProvider).value;
    final target = _targetMonth ?? active;

    if (target == null) return;
    final targetYearMonth = target.yearMonth;

    final code = CurrencyCode.tryParse(_effectiveCurrency) ?? CurrencyCode.huf;

    // US6 (T055): a save into a shared space is confirmed first, naming the
    // space, unless the user turned the guard off in Settings. A Main expense
    // already received the combined space + free-to-use confirmation.
    if (budgetContext.isShared &&
        !_destinationConfirmed &&
        ref.read(confirmSharedSaveOnProvider)) {
      final spaceName =
          ref.read(activeSpaceProvider).value?.name ?? 'this space';
      final title = _titleController.text.trim();
      final decision = await confirmSpaceOnSave(
        context,
        title: title.isEmpty ? 'Expense' : title,
        amountText: formatMoney(Money.fromMajor(amount, code)),
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

    final expense = Expense(
      profileId: budgetContext.isShared ? 0 : budgetContext.profileKey,
      sharedSpaceId: budgetContext.spaceId,
      yearMonth: targetYearMonth,
      title: _titleController.text,
      amount: parseSearchAmount(_amountController.text, code)!,
      currency: code.code.toUpperCase(),
      categoryId: _categoryId,
      status: _status,
      isReimbursable: _isReimbursable,
      guiltLevel: _guiltLevel,
      date: _purchaseDate ?? (throw StateError('Choose the expense date.')),
      paidAt: _status == ExpenseStatus.paid ? _purchaseDate : null,
      budgetId: target.id,
      // When the expense was started from a budget profile's card, it belongs
      // to that profile (FR-005, T129).
      budgetProfileId: _budgetProfileId,
      financialProfileType: _profileType,
      financialProfileSyncGuid: _profileSyncGuid,
    );

    _metadata.apply(expense);
    _metadata.evidence.apply(expense,
        actor:
            '${ref.read(actingProfileIdProvider) ?? budgetContext.profileKey}');
    await ref
        .read(expensesProvider.notifier)
        .addExpense(expense, targetBudgetId: target.id);
    if (!mounted) return;
    if (ref.read(selectedYearMonthProvider) != targetYearMonth) {
      ref.read(selectedYearMonthProvider.notifier).state = targetYearMonth;
    }
    showFinancialFeedback(
        context, 'Expense saved in ${monthLabel(targetYearMonth)}');
    context.pop();
  }

  /// The name of the profile the expense is filed under, for the field label.
  String? get _selectedProfileName {
    final id = _budgetProfileId;
    if (id == null) return null;
    for (final profile in ref.read(budgetProfilesProvider).value ?? const []) {
      if (_profileType == FinancialProfileType.budget && profile.id == id) {
        return profile.name;
      }
    }
    for (final profile
        in ref.read(directExpenseProfilesProvider).value ?? const []) {
      if (_profileType == FinancialProfileType.direct && profile.id == id) {
        return profile.name;
      }
    }
    return null;
  }

  /// Opens the searchable profile picker (T140) and stores the choice.
  Future<void> _pickProfile() async {
    final result = await ProfilePickerSheet.show(
      context,
      selectedProfileId: _budgetProfileId,
      selectedProfileType: _profileType,
    );
    // A `null` result means the sheet was dismissed, so the choice is kept.
    if (result == null) return;
    setState(() {
      _metadata.evidence.profileChosen = true;
      _metadata.evidence.changed = true;
      _budgetProfileId = result.profileId;
      _profileType = result.profileType;
      _profileSyncGuid = result.syncGuid;
    });
  }

  ({
    bool isMain,
    bool isDirect,
    String? name,
    Color? color,
    int? remainingMinor
  }) _destinationSnapshot() {
    final id = _budgetProfileId;
    if (id == null) {
      return (
        isMain: true,
        isDirect: false,
        name: null,
        color: null,
        remainingMinor: null,
      );
    }
    if (_profileType == FinancialProfileType.direct) {
      final rows = ref.read(directExpenseProfilesProvider).value ?? const [];
      for (final profile in rows) {
        if (profile.id == id &&
            (_profileSyncGuid == null ||
                profile.syncGuid == _profileSyncGuid)) {
          return (
            isMain: false,
            isDirect: true,
            name: profile.name,
            color: profileIdentity(context,
                syncGuid: profile.syncGuid, name: profile.name),
            remainingMinor: null,
          );
        }
      }
      return (
        isMain: false,
        isDirect: true,
        name: _selectedProfileName,
        color: null,
        remainingMinor: null,
      );
    }
    final rows = ref.read(budgetProfilesProvider).value ?? const [];
    for (final profile in rows) {
      if (profile.id == id &&
          (_profileSyncGuid == null || profile.syncGuid == _profileSyncGuid)) {
        return (
          isMain: false,
          isDirect: false,
          name: profile.name,
          color: profileIdentity(context,
              syncGuid: profile.syncGuid, name: profile.name),
          remainingMinor: profile.allocation - profile.spent,
        );
      }
    }
    return (
      isMain: false,
      isDirect: false,
      name: _selectedProfileName,
      color: null,
      remainingMinor: null,
    );
  }

  /// The entered amount in the context/main currency, used to compare against a
  /// budget profile's remaining allocation.
  int _expenseAmountInMain() {
    try {
      final code =
          CurrencyCode.tryParse(_effectiveCurrency) ?? CurrencyCode.huf;
      final minor = parseSearchAmount(_amountController.text, code) ?? 0;
      if (minor <= 0) return 0;
      final String month =
          _targetMonth?.yearMonth ?? ref.read(selectedYearMonthProvider);
      final table = ref.read(rateRegistryProvider).tableFor(month);
      return toDisplay(
              Money(minor, code), ref.read(mainCurrencyProvider), table)
          .minorUnits;
    } on FormatException {
      // The amount is invalid/oversized; the field validator reports it and no
      // destination comparison should crash the form.
      return 0;
    } catch (_) {
      return 0;
    }
  }

  void _setStatus(ExpenseStatus status) {
    setState(() {
      _status = status;
      _dateError = _purchaseDate != null &&
              isFuturePaidExpense(status, _purchaseDate!, DateTime.now())
          ? 'A paid expense cannot be dated in the future. Choose an earlier date.'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(activeBudgetProvider).value;
    final profile = ref.watch(activeProfileProvider).value;
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final main = ref.watch(mainCurrencyProvider);
    final targetMonth = _targetMonth ?? budget;
    final targetYearMonth = targetMonth?.yearMonth ?? yearMonth;
    final display =
        resolveDisplayCurrency(month: targetMonth, profile: profile);
    final table = ref.watch(rateRegistryProvider).tableFor(targetYearMonth);
    final theme = Theme.of(context), scheme = theme.colorScheme;
    InputDecoration field(String label) => InputDecoration(
          labelText: label,
          filled: true,
          fillColor: scheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        );

    // Read the profile lists only when a profile is selected; Main needs no
    // database read. Watching keeps the identity colour and remaining amount
    // current when the profiles load.
    if (_budgetProfileId != null) {
      if (_profileType == FinancialProfileType.direct) {
        ref.watch(directExpenseProfilesProvider);
      } else {
        ref.watch(budgetProfilesProvider);
      }
    }
    final destination = _destinationSnapshot();
    final amountMinorInContext = _expenseAmountInMain();
    final isMainProfile = destination.isMain;
    final profileColor = destination.color;
    final profileIcon = destination.isDirect
        ? Icons.receipt_long
        : Icons.account_balance_wallet;

    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      highlight: true,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text('How much?',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800)),
                              ),
                              _CurrencySelector(
                                currency: _effectiveCurrency,
                                items: _currencies,
                                onChanged: (val) => setState(() {
                                  _currency = val;
                                  _metadata.evidence.cashConfirmed = false;
                                }),
                              ),
                            ]),
                            MoneyField(
                              key: const Key('addExpenseAmountField'),
                              controller: _amountController,
                              textStyle: theme.textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                try {
                                  final v = parseSearchAmount(
                                      value,
                                      CurrencyCode.tryParse(
                                          _effectiveCurrency));
                                  if (v == null || v <= 0) return 'Must be > 0';
                                } on FormatException catch (error) {
                                  return error.message;
                                }
                                return null;
                              },
                            ),
                            AmountConversionHint(
                              amount: _parseAmount(_amountController.text),
                              currency:
                                  CurrencyCode.tryParse(_effectiveCurrency),
                              display: display,
                              main: main,
                              table: table,
                            ),
                          ]),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          const AppSectionHeader(
                            icon: Icons.edit_note_outlined,
                            title: 'What and where',
                            subtitle:
                                'Name it, then choose the profile and category.',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: field('What did you buy?'),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter a title'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          // T141: which profile the expense is filed under.
                          _BudgetProfileField(
                            profileName: _selectedProfileName,
                            isMain: isMainProfile,
                            profileColor: profileColor,
                            profileIcon: profileIcon,
                            onChange: _pickProfile,
                          ),
                          const SizedBox(height: 8),
                          _DestinationLine(
                            isMain: isMainProfile,
                            isDirect: destination.isDirect,
                            profileName:
                                destination.name ?? _selectedProfileName,
                            profileColor: profileColor,
                            remainingMinor: destination.remainingMinor,
                            amountMinorInContext: amountMinorInContext,
                            currency: main,
                          ),
                          const SizedBox(height: 12),
                          ref.watch(categoriesProvider).when(
                                data: (categories) =>
                                    DropdownButtonFormField<String>(
                                  initialValue: _categoryId,
                                  isExpanded: true,
                                  decoration: field('Category'),
                                  items: categories
                                      .map((c) => DropdownMenuItem(
                                            value: c.categoryId,
                                            child: Text('${c.emoji} ${c.name}'),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _categoryId = val);
                                    }
                                  },
                                ),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (_, __) =>
                                    const Text('Error loading categories'),
                              ),
                        ])),
                    const SizedBox(height: 16),
                    AppCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          const AppSectionHeader(
                            icon: Icons.event_outlined,
                            title: 'When',
                            subtitle:
                                'Past dates are recorded in their own month.',
                          ),
                          const SizedBox(height: 12),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            ChoiceChip(
                              label: const Text('Paid'),
                              selected: _status == ExpenseStatus.paid,
                              onSelected: (_) => _setStatus(ExpenseStatus.paid),
                            ),
                            ChoiceChip(
                              label: const Text('Planned'),
                              selected: _status == ExpenseStatus.planned,
                              onSelected: (_) =>
                                  _setStatus(ExpenseStatus.planned),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.calendar_month_outlined,
                                color: scheme.primary),
                            title: Text(_purchaseDate == null
                                ? 'Choose expense date *'
                                : '${_purchaseDate!.day}/${_purchaseDate!.month}/${_purchaseDate!.year}'),
                            subtitle: Text(_purchaseDate == null
                                ? 'Past dates are filed into their own month.'
                                : 'Recorded in ${monthLabel(currentYearMonth(_purchaseDate!))}'),
                            trailing: _resolvingMonth
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.edit_calendar_outlined),
                            onTap: _resolvingMonth ? null : _pickDate,
                          ),
                          if (_dateError != null)
                            Text(_dateError!,
                                style: TextStyle(color: scheme.error)),
                        ])),
                    const SizedBox(height: 16),
                    AppCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          const AppSectionHeader(
                            icon: Icons.tune_outlined,
                            title: 'Details',
                            subtitle: 'Optional notes and payment evidence.',
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Reimbursable'),
                            subtitle:
                                const Text('Money someone may return to you.'),
                            value: _isReimbursable,
                            onChanged: (val) =>
                                setState(() => _isReimbursable = val),
                          ),
                          if (!_metadata.evidence.profileChosen)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Choose your financial profile above, including Main.',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ExpenseMetadataFields(
                              draft: _metadata,
                              status: _status,
                              requiredMetadata: true),
                          const SizedBox(height: 12),
                          Text('How did you feel about this?',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          EmotionSelector(
                            selectedLevel: _guiltLevel,
                            onSelected: (level) =>
                                setState(() => _guiltLevel = level),
                          ),
                        ])),
                  ],
                ),
              ),
            ),
            _SaveBar(
              saving: _saving,
              disabled: _resolvingMonth,
              onPressed: _saveExpense,
            ),
          ]),
        ),
      ),
    );
  }
}

/// The "Budget Profile" field of the Add Expense form (T141).
///
/// It shows the profile the expense will be filed under, and a "Change"
/// button opens the searchable picker with both profile types. The leading
/// avatar carries the profile's stable identity colour; the unbudgeted
/// destination uses the error colour so it never reads as a normal profile.
class _BudgetProfileField extends StatelessWidget {
  const _BudgetProfileField({
    required this.profileName,
    required this.isMain,
    required this.profileColor,
    required this.profileIcon,
    required this.onChange,
  });

  /// The name of the chosen profile, or `null` for the unbudgeted destination.
  final String? profileName;

  final bool isMain;
  final Color? profileColor;
  final IconData profileIcon;

  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final color = isMain ? scheme.error : (profileColor ?? scheme.primary);
    final label =
        isMain ? 'No budget — free-to-use' : (profileName ?? 'Profile');
    final largeText = MediaQuery.textScalerOf(context).scale(16) > 24;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isMain
                ? scheme.error.withValues(alpha: .55)
                : scheme.outlineVariant),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor:
              isMain ? scheme.errorContainer : color.withValues(alpha: .16),
          child: Icon(profileIcon,
              size: 20, color: isMain ? scheme.onErrorContainer : color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Financial profile',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
              Text(label,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (largeText)
          IconButton(
            tooltip: 'Change profile',
            onPressed: onChange,
            icon: const Icon(Icons.swap_horiz),
          )
        else
          TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8)),
            onPressed: onChange,
            child: const Text('Change'),
          ),
      ]),
    );
  }
}

class _DestinationLine extends StatelessWidget {
  const _DestinationLine({
    required this.isMain,
    required this.isDirect,
    required this.profileName,
    required this.profileColor,
    required this.remainingMinor,
    required this.amountMinorInContext,
    required this.currency,
  });

  final bool isMain, isDirect;
  final String? profileName;
  final Color? profileColor;
  final int? remainingMinor;
  final int amountMinorInContext;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final exhausted = !isMain && !isDirect && (remainingMinor ?? 0) <= 0;
    final borrow = !isMain &&
            !isDirect &&
            remainingMinor != null &&
            remainingMinor! > 0 &&
            amountMinorInContext > remainingMinor!
        ? amountMinorInContext - remainingMinor!
        : 0;
    final warning = isMain || isDirect || exhausted || borrow > 0;
    final tone = isMain ? scheme.error : (profileColor ?? scheme.primary);
    final name = profileName ?? (isDirect ? 'Direct profile' : 'Budget');
    final covered =
        remainingMinor != null && amountMinorInContext > remainingMinor!
            ? remainingMinor!
            : amountMinorInContext;
    final text = isMain
        ? 'Paid from free-to-use (no budget)'
        : isDirect
            ? '$name · paid from free-to-use'
            : remainingMinor != null && remainingMinor! > 0
                ? amountMinorInContext > 0
                    ? '$name · Uses ${formatMinorUnits(covered, currency)} '
                        'from this allocation; '
                        '${formatMinorUnits(amountMinorInContext - covered, currency)} '
                        'from free-to-use'
                    : '$name budget · '
                        '${formatMinorUnits(remainingMinor!, currency)} left'
                : '$name · no allocation left, paid from free-to-use';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: warning ? .14 : .10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: warning ? .45 : .35)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(warning ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 18, color: tone),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: warning ? tone : scheme.onSurfaceVariant,
                  fontWeight: warning ? FontWeight.w600 : null)),
        ),
      ]),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar(
      {required this.saving, required this.disabled, required this.onPressed});

  final bool saving, disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('saveExpenseButton'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: saving || disabled ? null : onPressed,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(saving ? 'Saving…' : 'Save expense'),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector(
      {required this.currency, required this.items, required this.onChanged});

  final String currency;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      tooltip: 'Currency',
      initialValue: currency,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final code in items) PopupMenuItem(value: code, child: Text(code))
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(currency, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, size: 18),
        ]),
      ),
    );
  }
}
