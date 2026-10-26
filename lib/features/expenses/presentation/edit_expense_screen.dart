import 'widgets/expense_metadata_fields.dart';
import 'purchase_screen.dart';
import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import '../../../core/services/expense_evidence.dart';
import '../../../core/services/filter_service.dart';
import '../../../core/services/fx_booking_service.dart';
import '../../../core/models/fx_revision.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/network/rate_types.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/money_field.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/expense_delta.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/safe_to_spend_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/category_provider.dart';
import '../../finance/providers/profile_providers.dart';
import 'profile_picker_sheet.dart';
import 'widgets/amount_conversion_hint.dart';
import 'widgets/emotion_selector.dart';

/// Full edit form for an existing [Expense]. Reuses the AddExpense field set,
/// adds a live "smart overspend" warning and a Duplicate action.
class EditExpenseScreen extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  static const _currencies = ['USD', 'EUR', 'HUF', 'CAD'];

  late final ExpenseMetadataDraft _metadata;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final String _originalAmountText;

  late final ExpenseSnapshot _original;
  late String _currency;
  late ExpenseStatus _status;
  late bool _isReimbursable;
  late GuiltLevel _guiltLevel;
  late String _categoryId;
  late DateTime _purchaseDate;
  int? _budgetProfileId;
  String? _profileType, _profileGuid;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _metadata = ExpenseMetadataDraft(e);
    _original = ExpenseSnapshot.of(e);
    _titleController = TextEditingController(text: e.title);
    _originalAmountText =
        formatMinorUnitsInput(e.amount, e.currencyCode ?? CurrencyCode.huf);
    _amountController = TextEditingController(text: _originalAmountText)
      ..addListener(() => setState(() {
            _metadata.evidence.cashConfirmed = false;
          }));
    _currency = e.currency.toUpperCase();
    _status = e.status;
    _isReimbursable = e.isReimbursable;
    _guiltLevel = e.guiltLevel;
    _categoryId = e.categoryId;
    _purchaseDate = e.date;
    _budgetProfileId = e.budgetProfileId;
    _profileType = e.financialProfileType;
    _profileGuid = e.financialProfileSyncGuid;
  }

  @override
  void dispose() {
    _metadata.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  static double? _parseAmount(String? raw) => parseMoneyInput(raw ?? '');

  Future<void> _onCurrencyChanged(String currency) async {
    setState(() {
      _currency = currency;
      _metadata.evidence.cashConfirmed = false;
    });
  }

  // ---- T013: live delta vs. the stored expense --------------------------
  ExpenseDelta _currentDelta(CurrencyCode display, RateTable? table) {
    final code = CurrencyCode.tryParse(_currency);
    if (code == null) return ExpenseDelta.zero;
    int? amount;
    try {
      amount = parseSearchAmount(_amountController.text, code);
    } on FormatException {
      return ExpenseDelta.zero;
    }
    if (amount == null || amount <= 0) return ExpenseDelta.zero;
    final booked = expenseFx(widget.expense)?.current;
    var afterAmount = amount;
    var afterCurrency = code;
    if (booked != null &&
        fxPaid(widget.expense.status) &&
        fxPaid(_status) &&
        code == widget.expense.currencyCode) {
      afterCurrency = booked.money.currency;
      afterAmount = fxConvertMinor(
          amount, code, afterCurrency, booked.numerator, booked.denominator);
    }
    double toPrimary(ExpenseSnapshot s) {
      final from = s.currency;
      if (from == null) return 0.0;
      return toDisplay(Money(s.amount, from), display, table).majorValue;
    }

    return ExpenseDelta.between(
      before: _original,
      after: ExpenseSnapshot(
        amount: afterAmount,
        currency: afterCurrency,
        status: _status,
      ),
      toPrimary: toPrimary,
    );
  }

  // ---- T006: save --------------------------------------------------------
  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final code = CurrencyCode.tryParse(_currency);
    final e = widget.expense.copyForEditing()
      ..budgetProfileId = _budgetProfileId
      ..financialProfileType = _profileType
      ..financialProfileSyncGuid = _profileGuid
      ..title = _titleController.text.trim()
      ..paidAt =
          _status == ExpenseStatus.paid && _purchaseDate != widget.expense.date
              ? _purchaseDate
              : widget.expense.paidAt
      ..date = _purchaseDate
      ..amount = code == null
          ? widget.expense.amount
          : parseSearchAmount(_amountController.text, code)!
      ..currency = _currency == widget.expense.currency.toUpperCase()
          ? widget.expense.currency
          : _currency
      ..categoryId = _categoryId
      ..status = _status
      ..isReimbursable = _isReimbursable
      ..guiltLevel = _guiltLevel;

    try {
      _metadata.apply(e);
      if (e.status == ExpenseStatus.paid &&
          widget.expense.status != ExpenseStatus.paid) {
        e.paidAt ??= e.date;
      }
      _metadata.evidence.apply(e,
          actor: '${ref.read(actingProfileIdProvider) ?? e.profileId}');
      await ref.read(expensesProvider.notifier).updateExpense(e);
      if (!mounted) return;
      showFinancialFeedback(context, 'Expense updated');
      context.pop();
    } catch (err) {
      if (!mounted) return;
      setState(() => _saving = false);
      showFinancialFeedback(
          context,
          err is StateError
              ? err.message.toString()
              : 'Expense could not be saved. Please retry.',
          kind: FinancialFeedbackKind.error);
    }
  }

  // ---- T012: duplicate ---------------------------------------------------
  Future<void> _duplicate() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final budget = ref.read(activeBudgetProvider).value;
    if (budget == null) return;
    setState(() => _saving = true);

    final src = widget.expense;
    final code = CurrencyCode.tryParse(_currency);
    if (code == null) {
      setState(() => _saving = false);
      showFinancialFeedback(
          context, 'Choose a supported currency before making a new copy.',
          kind: FinancialFeedbackKind.error);
      return;
    }
    final clone = Expense(
      profileId: src.profileId,
      sharedSpaceId: src.sharedSpaceId,
      yearMonth: budget.yearMonth,
      type: src.type,
      title: _titleController.text.trim(),
      amount: parseSearchAmount(_amountController.text, code)!,
      currency: _currency,
      categoryId: _categoryId,
      status: ExpenseStatus.planned,
      isReimbursable: _isReimbursable,
      guiltLevel: _guiltLevel,
      date: _purchaseDate,
      notes: src.notes,
      budgetId: budget.id,
      budgetProfileId: _budgetProfileId,
      financialProfileType: _profileType,
      financialProfileSyncGuid: _profileGuid,
      paidAt: null,
    );

    _metadata.apply(clone);
    clone.paymentEvidenceJson =
        ExpenseEvidence(profileChosen: _metadata.evidence.profileChosen)
            .encode();
    final problems = expenseEvidenceProblems(clone);
    if (problems.isNotEmpty) {
      setState(() => _saving = false);
      showFinancialFeedback(context, problems.join(' '),
          kind: FinancialFeedbackKind.error);
      return;
    }
    final saved = await runFinancialAction(context,
        action: () => ref.read(expensesProvider.notifier).addExpense(clone),
        success: 'Planned copy created without payment evidence',
        failure: 'Expense could not be duplicated. Please retry.');
    if (!mounted) return;
    if (saved) {
      context.pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expense.purchaseSyncGuid != null) {
      return PurchaseScreen(guid: widget.expense.purchaseSyncGuid!);
    }
    var profileLabel =
        _budgetProfileId == null && _profileGuid == null && _profileType == null
            ? 'Main Profile'
            : 'Needs profile review';
    for (final profile
        in ref.watch(budgetProfilesProvider).asData?.value ?? const []) {
      if (_profileType == FinancialProfileType.budget &&
          profile.id == _budgetProfileId &&
          (_profileGuid == null || profile.syncGuid == _profileGuid)) {
        profileLabel = profile.name;
      }
    }
    for (final profile
        in ref.watch(directExpenseProfilesProvider).asData?.value ?? const []) {
      if (_profileType == FinancialProfileType.direct &&
          profile.id == _budgetProfileId &&
          (_profileGuid == null || profile.syncGuid == _profileGuid)) {
        profileLabel = profile.name;
      }
    }
    final budget = ref.watch(activeBudgetProvider).value;
    final profile = ref.watch(activeProfileProvider).value;
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
    final main = ref.watch(mainCurrencyProvider);
    final display = resolveDisplayCurrency(month: budget, profile: profile);
    final safeToSpend = ref.watch(safeToSpendProvider);
    final delta = _currentDelta(display, table);
    final overspend = delta.wouldOverspend(safeToSpend);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _saving ? null : _save,
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
              // ---- T014: animated smart warning ----
              _OverspendWarning(
                visible: overspend,
                message: overspend
                    ? 'This change puts you '
                        '${formatMoney(Money.fromMajor((safeToSpend + delta.safeToSpendDelta).abs(), display))} '
                        'over your safe-to-spend.'
                    : '',
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'What did you buy?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: MoneyField(
                      key: const Key('editExpenseAmountField'),
                      controller: _amountController,
                      label: 'Amount',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (CurrencyCode.tryParse(_currency) == null &&
                            value == _originalAmountText) {
                          return null;
                        }
                        try {
                          final v = parseSearchAmount(
                              value, CurrencyCode.tryParse(_currency));
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
                      isExpanded: true,
                      initialValue: _currency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        ..._currencies.map(
                            (c) => DropdownMenuItem(value: c, child: Text(c))),
                        if (!_currencies.contains(_currency))
                          DropdownMenuItem(
                              value: _currency,
                              enabled: false,
                              child: Text(_currency.isEmpty
                                  ? 'Legacy: not recorded'
                                  : '$_currency (legacy)'))
                      ],
                      onChanged: (val) {
                        if (val != null) _onCurrencyChanged(val);
                      },
                    ),
                  ),
                ],
              ),
              AmountConversionHint(
                amount: _parseAmount(_amountController.text),
                currency: CurrencyCode.tryParse(_currency),
                display: display,
                main: main,
                table: table,
              ),
              const SizedBox(height: 16),
              if (CurrencyCode.tryParse(_currency) == null)
                const Text(
                    'This legacy amount is in recorded minor units. Choose a supported currency before changing its amount.'),
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
              if (_status == ExpenseStatus.paid ||
                  _status == ExpenseStatus.planned)
                SegmentedButton<ExpenseStatus>(
                  segments: const [
                    ButtonSegment(
                        value: ExpenseStatus.paid,
                        label: Text('Paid'),
                        icon: Icon(Icons.check)),
                    ButtonSegment(
                        value: ExpenseStatus.planned,
                        label: Text('Planned'),
                        icon: Icon(Icons.schedule)),
                  ],
                  selected: {_status},
                  onSelectionChanged: (s) => setState(() => _status = s.first),
                )
              else
                Text(
                    'Status: ${_status == ExpenseStatus.cancelled ? 'Cancelled' : _status == ExpenseStatus.reimbursed ? 'Reimbursed' : 'Partially reimbursed'}'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is this reimbursable?'),
                value: _isReimbursable,
                onChanged: (val) => setState(() => _isReimbursable = val),
              ),
              const SizedBox(height: 16),
              if (widget.expense.type == ExpenseType.standard)
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('Financial profile'),
                    subtitle: Text(profileLabel),
                    trailing: TextButton(
                        onPressed: () async {
                          final choice = await ProfilePickerSheet.show(context,
                              selectedProfileId: _budgetProfileId,
                              selectedProfileType: _profileType);
                          if (choice != null && mounted) {
                            setState(() {
                              _budgetProfileId = choice.profileId;
                              _profileType = choice.profileType;
                              _profileGuid = choice.syncGuid;
                              _metadata.evidence.profileChosen = true;
                              _metadata.evidence.changed = true;
                              _metadata.evidence.cashConfirmed = false;
                            });
                          }
                        },
                        child: Text(_metadata.evidence.profileChosen
                            ? 'Change'
                            : 'Choose'))),
              if (widget.expense.type == ExpenseType.standard)
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Expense date'),
                    subtitle: Text(DateFormat.yMMMd().format(_purchaseDate)),
                    trailing: const Icon(Icons.edit_calendar_outlined),
                    onTap: () async {
                      final parts = widget.expense.yearMonth
                          .split('-')
                          .map(int.parse)
                          .toList();
                      final first = DateTime(parts[0], parts[1]),
                          last = DateTime(parts[0], parts[1] + 1, 0);
                      final selected = await showDatePicker(
                          context: context,
                          initialDate: _purchaseDate,
                          firstDate: first,
                          lastDate: last);
                      if (selected != null && mounted) {
                        setState(() {
                          _purchaseDate = selected;
                          _metadata.evidence.cashConfirmed = false;
                        });
                      }
                    }),
              ExpenseMetadataFields(
                  draft: _metadata,
                  status: _status,
                  showEvidence: widget.expense.type == ExpenseType.standard),
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
                  onPressed: _saving ? null : _save,
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 12),
              // ---- T011: duplicate button ----
              if (widget.expense.type == ExpenseType.standard)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _duplicate,
                    icon: const Icon(Icons.copy_all_rounded),
                    label: const Text('Duplicate Expense'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Playful, animated banner that slides/bounces in when an edit would push
/// safe-to-spend below zero.
class _OverspendWarning extends StatelessWidget {
  final bool visible;
  final String message;

  const _OverspendWarning({required this.visible, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => SizeTransition(
          sizeFactor: anim,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
            child: child,
          ),
        ),
        child: !visible
            ? const SizedBox(width: double.infinity, key: ValueKey('none'))
            : Padding(
                key: const ValueKey('warn'),
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: scheme.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text('🙈', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Whoa there!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onErrorContainer)),
                            const SizedBox(height: 2),
                            Text(message,
                                style:
                                    TextStyle(color: scheme.onErrorContainer)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
