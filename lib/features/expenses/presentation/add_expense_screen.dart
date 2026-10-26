import 'widgets/expense_metadata_fields.dart';
import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import '../../../core/services/filter_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/confirm_space_on_save.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/money_field.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../finance/providers/profile_providers.dart';
import '../providers/expenses_provider.dart';
import '../providers/category_provider.dart';
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

  Future<void> _saveExpense() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
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
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveValidatedExpense() async {
    final amount = _parseAmount(_amountController.text) ?? 0.0;
    final budgetContext = ref.read(budgetContextProvider);
    final budget = ref.read(activeBudgetProvider).value;

    if (budget == null) return;

    final code = CurrencyCode.tryParse(_effectiveCurrency) ?? CurrencyCode.huf;

    // US6 (T055): a save into a shared space is confirmed first, naming the
    // space, unless the user turned the guard off in Settings.
    if (budgetContext.isShared && ref.read(confirmSharedSaveOnProvider)) {
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
      yearMonth: budget.yearMonth,
      title: _titleController.text,
      amount: parseSearchAmount(_amountController.text, code)!,
      currency: code.code.toUpperCase(),
      categoryId: _categoryId,
      status: _status,
      isReimbursable: _isReimbursable,
      guiltLevel: _guiltLevel,
      date: _purchaseDate ?? (throw StateError('Choose the expense date.')),
      paidAt: _status == ExpenseStatus.paid ? _purchaseDate : null,
      budgetId: budget.id,
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
    await ref.read(expensesProvider.notifier).addExpense(expense);
    if (mounted) {
      showFinancialFeedback(context, 'Expense saved');
      context.pop();
    }
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

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(activeBudgetProvider).value;
    final profile = ref.watch(activeProfileProvider).value;
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final main = ref.watch(mainCurrencyProvider);
    final display = resolveDisplayCurrency(month: budget, profile: profile);
    final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saving ? null : _saveExpense,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'What did you buy?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: MoneyField(
                      key: const Key('addExpenseAmountField'),
                      controller: _amountController,
                      label: 'Amount',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        try {
                          final v = parseSearchAmount(
                              value, CurrencyCode.tryParse(_effectiveCurrency));
                          if (v == null || v <= 0) return 'Must be > 0';
                        } on FormatException catch (error) {
                          return error.message;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_effectiveCurrency),
                      initialValue: _effectiveCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: _currencies
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _currency = val;
                            _metadata.evidence.cashConfirmed = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              AmountConversionHint(
                amount: _parseAmount(_amountController.text),
                currency: CurrencyCode.tryParse(_effectiveCurrency),
                display: display,
                main: main,
                table: table,
              ),
              const SizedBox(height: 16),
              // T141: which profile the expense is filed under. The chosen
              // profile is shown by name, so it is never a mystery.
              _BudgetProfileField(
                profileName: _selectedProfileName,
                onChange: _pickProfile,
              ),
              const SizedBox(height: 16),
              ref.watch(categoriesProvider).when(
                    data: (categories) => DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c.categoryId,
                                child: Text('${c.emoji} ${c.name}'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _categoryId = val);
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error loading categories'),
                  ),
              const SizedBox(height: 16),
              SegmentedButton<ExpenseStatus>(
                segments: const [
                  ButtonSegment(value: ExpenseStatus.paid, label: Text('Paid')),
                  ButtonSegment(
                      value: ExpenseStatus.planned, label: Text('Planned')),
                ],
                selected: {_status},
                onSelectionChanged: (Set<ExpenseStatus> newSelection) {
                  setState(() {
                    _status = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is this reimbursable?'),
                value: _isReimbursable,
                onChanged: (val) => setState(() => _isReimbursable = val),
              ),
              const SizedBox(height: 16),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(_purchaseDate == null
                      ? 'Choose expense date *'
                      : '${_purchaseDate!.day}/${_purchaseDate!.month}/${_purchaseDate!.year}'),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final parts = yearMonth.split('-').map(int.parse).toList();
                    final first = DateTime(parts[0], parts[1]);
                    final last = DateTime(parts[0], parts[1] + 1, 0);
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: _purchaseDate ??
                            (DateTime.now().isAfter(last)
                                ? last
                                : DateTime.now().isBefore(first)
                                    ? first
                                    : DateTime.now()),
                        firstDate: first,
                        lastDate: last);
                    if (picked != null && mounted) {
                      setState(() {
                        _purchaseDate = picked;
                        _metadata.evidence.cashConfirmed = false;
                      });
                    }
                  }),
              if (!_metadata.evidence.profileChosen)
                const Text(
                    'Choose your financial profile above, including Main.',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ExpenseMetadataFields(
                  draft: _metadata, status: _status, requiredMetadata: true),
              const SizedBox(height: 16),
              const Text('How did you feel about this?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              EmotionSelector(
                selectedLevel: _guiltLevel,
                onSelected: (level) => setState(() => _guiltLevel = level),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveExpense,
                  child: const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "Budget Profile" field of the Add Expense form (T141).
///
/// It shows the profile the expense will be filed under, and a "Change"
/// button opens the searchable picker with both profile types.
class _BudgetProfileField extends StatelessWidget {
  const _BudgetProfileField(
      {required this.profileName, required this.onChange});

  /// The name of the chosen profile, or `null` for the Main Profile.
  final String? profileName;

  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Financial profile *',
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Icon(
            profileName == null
                ? Icons.account_balance_wallet
                : Icons.check_circle_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              profileName ?? 'Main Profile',
              style: theme.textTheme.bodyLarge,
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
