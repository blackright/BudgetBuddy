import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/exchange_rate_cache.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../engine/expense_delta.dart';
import '../../engine/providers/safe_to_spend_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/category_provider.dart';
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
  static const _currencies = ['USD', 'EUR', 'GBP', 'HUF', 'CAD'];
  static final _money = NumberFormat('#,##0.00');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  late final ExpenseSnapshot _original;
  late String _currency;
  late ExpenseStatus _status;
  late bool _isReimbursable;
  late GuiltLevel _guiltLevel;
  late String _categoryId;

  /// Rate for the currently selected currency → primary. Starts as the
  /// expense's locked-in rate and is refreshed if the currency changes.
  late double _rate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _original = ExpenseSnapshot.of(e);
    _titleController = TextEditingController(text: e.title);
    _amountController = TextEditingController(text: _formatEditable(e.amount))
      ..addListener(() => setState(() {}));
    _currency = _currencies.contains(e.currency) ? e.currency : 'USD';
    _status =
        e.status == ExpenseStatus.cancelled ? ExpenseStatus.planned : e.status;
    _isReimbursable = e.isReimbursable;
    _guiltLevel = e.guiltLevel;
    _categoryId = e.categoryId;
    _rate = e.exchangeRateToPrimary;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  static String _formatEditable(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  static double? _parseAmount(String? raw) =>
      double.tryParse((raw ?? '').replaceAll(RegExp(r'[,\s]'), ''));

  String _symbol(PrimaryCurrency? c) {
    switch (c) {
      case PrimaryCurrency.huf:
        return 'Ft';
      case PrimaryCurrency.cad:
        return 'C\$';
      case PrimaryCurrency.eur:
        return '€';
      case PrimaryCurrency.usd:
      case null:
        return '\$';
    }
  }

  Future<void> _onCurrencyChanged(String currency) async {
    setState(() => _currency = currency);
    if (currency == widget.expense.currency) {
      setState(() => _rate = widget.expense.exchangeRateToPrimary);
      return;
    }
    final budget = ref.read(activeBudgetProvider).value;
    if (budget == null) return;
    final rate = await ref
        .read(exchangeRateCacheProvider)
        .getRate(currency, budget.currency.name.toUpperCase());
    if (mounted && _currency == currency) setState(() => _rate = rate);
  }

  // ---- T013: live delta vs. the stored expense --------------------------
  ExpenseDelta _currentDelta() {
    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0) return ExpenseDelta.zero;
    return ExpenseDelta.between(
      before: _original,
      after: ExpenseSnapshot(
        amount: amount,
        exchangeRateToPrimary: _rate,
        status: _status,
      ),
    );
  }

  // ---- T006: save --------------------------------------------------------
  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final e = widget.expense
      ..title = _titleController.text.trim()
      ..amount = _parseAmount(_amountController.text)!
      ..currency = _currency
      ..categoryId = _categoryId
      ..status = _status
      ..isReimbursable = _isReimbursable
      ..guiltLevel = _guiltLevel;

    try {
      await ref.read(expensesProvider.notifier).updateExpense(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense updated ✨')),
      );
      context.pop();
    } catch (err) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $err')),
      );
    }
  }

  // ---- T012: duplicate ---------------------------------------------------
  Future<void> _duplicate() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final budget = ref.read(activeBudgetProvider).value;
    if (budget == null) return;
    setState(() => _saving = true);

    final src = widget.expense;
    final now = DateTime.now();
    final clone = Expense(
      profileId: src.profileId,
      yearMonth: budget.yearMonth,
      exchangeRateToPrimary: _rate,
      type: src.type,
      title: _titleController.text.trim(),
      amount: _parseAmount(_amountController.text)!,
      currency: _currency,
      categoryId: _categoryId,
      status: _status,
      isReimbursable: _isReimbursable,
      guiltLevel: _guiltLevel,
      date: now,
      receiptPath: src.receiptPath,
      notes: src.notes,
      budgetId: budget.id,
      paidAt: _status == ExpenseStatus.paid ? now : null,
    );

    await ref.read(expensesProvider.notifier).addExpense(clone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicated "${clone.title}" for today 👯')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final safeToSpend = ref.watch(safeToSpendProvider);
    final symbol = _symbol(ref.watch(activeBudgetProvider).value?.currency);
    final delta = _currentDelta();
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
                    ? 'This change puts you $symbol '
                        '${_money.format((safeToSpend + delta.safeToSpendDelta).abs())} '
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
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final v = _parseAmount(value);
                        if (v == null) return 'Invalid amount';
                        if (v <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: _currencies
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) _onCurrencyChanged(val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ref.watch(categoriesProvider).when(
                data: (categories) => DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((c) => DropdownMenuItem(
                    value: c.categoryId,
                    child: Text('${c.emoji} ${c.name}'),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _categoryId = val);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading categories'),
              ),
              const SizedBox(height: 16),
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
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is this reimbursable?'),
                value: _isReimbursable,
                onChanged: (val) => setState(() => _isReimbursable = val),
              ),
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
                    border: Border.all(color: scheme.error.withOpacity(0.4)),
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
