import '../../../core/services/merchant_service.dart';
import '../../../core/services/expense_evidence.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/income_source.dart';
import 'dart:convert';
import '../../../core/models/currency_code.dart';
import '../../../core/models/money.dart';
import '../../../core/models/fx_revision.dart';
import '../../../shared/presentation/money_format.dart';
import '../../vault/presentation/vault_time.dart';

/// Render business values from original evidence; never recalculate old money.
String formatAuditValues(String? raw, {String? objectType}) {
  if (raw == null || raw == 'null') return 'No value';
  try {
    final data = jsonDecode(raw);
    if (data is Map) {
      void name(String field, List<String> values) {
        final value = data[field];
        if (value is int) {
          data[field] = value >= 0 && value < values.length
              ? _label(values[value])
              : '$value (needs review)';
        }
      }

      if (objectType == 'Expense') {
        final payment = data['paymentMethod'];
        if (payment is String) {
          data['paymentMethod'] = expensePaymentMethods[payment] ?? payment;
        }
        name('status', ExpenseStatus.values.map((v) => v.name).toList());
      }
      if (objectType == 'SharedMember') {
        name('role', SharedMemberRole.values.map((v) => v.name).toList());
      }
      if (objectType == 'IncomeSource') {
        name('type', IncomeSourceType.values.map((v) => v.name).toList());
        name('frequency', IncomeFrequency.values.map((v) => v.name).toList());
      }
    }
    return _describe(data);
  } on FormatException {
    return raw;
  }
}

const _internal = {
  'id',
  'syncGuid',
  'profileId',
  'sharedSpaceId',
  'budgetId',
  'budgetProfileId',
  'financialProfileSyncGuid',
  'purchaseEvidenceOwnerGuid',
  'itemGuids',
  'revision',
  'versionToken',
  'accountingCurrency',
  'auditEventId'
};
const _minor = {
  'receiptTotalMinor',
  'amount',
  'amountMinor',
  'allocation',
  'spent',
  'borrowed',
  'deficit',
  'balanceAfterMinor',
  'totalMinor',
  'returned',
  'originalPaid',
  'freeBefore',
  'freeAfter',
  'bankBefore',
  'bankAfter',
  'reserveBefore',
  'reserveAfter',
  'carriedMinor',
  'releasedMinor'
};
const _major = {'baseAvailableAmount', 'netSalaryOverride', 'defaultNetSalary'};

String _describe(Object? value, [CurrencyCode? inherited, String? key]) {
  if (key == 'fxHistoryJson') return _fxSummary(value);
  if (value is Map) {
    final currency = CurrencyCode.tryParse((value['accountingCurrency'] ??
                    value['contextCurrency'] ??
                    value['currency'])
                ?.toString() ??
            '') ??
        inherited;
    return value.entries
        .where((entry) => !_technicalField(entry.key.toString()))
        .map((entry) {
      final label = entry.value is Map && entry.value['name'] is String
          ? entry.value['name'] as String
          : _sentence(entry.key.toString());
      final nested = entry.value is Map || entry.value is List;
      return '$label:${nested ? '\n' : ' '}${_describe(entry.value, currency, entry.key.toString())}';
    }).join('\n');
  }
  if (value is List) {
    return value.map((item) => _describe(item, inherited)).join('\n');
  }
  if (value == null) return 'No value';
  if (value is String &&
      key != null &&
      (key == 'currency' || key.endsWith('Currency'))) {
    return value.toUpperCase();
  }
  if (value is bool) return value ? 'Yes' : 'No';
  if (inherited != null && _minor.contains(key) && value is int) {
    if (value < -9007199254740991 || value > 9007199254740991) {
      return '$value (original invalid value)';
    }
    return formatMinorUnits(value, inherited);
  }
  if (inherited != null && _major.contains(key) && value is num) {
    if (!value.isFinite ||
        value.abs() * inherited.minorUnitsPerMajor > 9007199254740991) {
      return '$value (original invalid value)';
    }
    return formatMinorUnits(
        Money.fromMajor(value.toDouble(), inherited).minorUnits, inherited);
  }
  if (value is int && key != null && (key.endsWith('At') || key == 'date')) {
    try {
      // Native Isar JSON exports epoch microseconds; web uses milliseconds.
      // Modern native values exceed the millisecond range for year 9999.
      // This only decodes presentation; original signed evidence is untouched.
      final date = value.abs() > 253402300799999
          ? DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
          : DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      if (date.year < 1 || date.year > 9999) {
        return '$value (date needs review)';
      }
      return formatVaultTime(date);
    } on ArgumentError {
      return '$value (date needs review)';
    }
  }
  if (value is String && key != null && key.endsWith('Json')) {
    try {
      return _describe(jsonDecode(value), inherited);
    } on FormatException {
      return value;
    }
  }
  return value.toString();
}

String _label(String key) => key.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]![0].toLowerCase()}');

bool _technicalField(String key) =>
    _internal.contains(key) ||
    key.endsWith('SyncGuid') ||
    key.endsWith('Id') ||
    key == 'operationKey' ||
    key == 'fingerprint';

String _fxSummary(Object? value) {
  try {
    final history = FxHistory.decode(value as String?);
    if (history == null) return 'Legacy · Original payment rate not recorded';
    final booked = history.current;
    return '${formatMinorUnits(booked.baseMinor, booked.money.currency)} fixed · ${history.revisions.length} revision${history.revisions.length == 1 ? '' : 's'} · ${booked.source}';
  } on Object {
    return 'Accounting evidence needs review';
  }
}

const _objectLabels = {
  'expensepurchase': 'Purchase',
  'expense': 'Expense',
  'incomesource': 'Income source',
  'income': 'Income',
  'budgetprofile': 'Budget profile',
  'directexpenseprofile': 'Direct expense profile',
  'monthlybudget': 'Monthly funds',
  'allocation': 'Allocation',
  'transfer': 'Transfer',
  'reimbursement': 'Reimbursement',
  'sharedspace': 'Shared space',
  'sharedmember': 'Member',
  'financialstate': 'Borrowing and deficit',
  'vaultentry': 'Savings Vault entry',
  'monthendrun': 'Month-End settlement',
  'medicalbill': 'Medical bill',
};

String auditObjectLabel(String type) =>
    _objectLabels[type.toLowerCase()] ?? _sentence(type);

/// Labels only: raw action codes remain the filter values and signed evidence.
String auditActionLabel(String action) {
  final normalized = action.toLowerCase();
  const special = {
    'expense.refund': 'Expense refunded',
    'expense.reversal': 'Expense payment reversed',
    'borrowing.deficit.change': 'Borrowing and deficit changed',
    'month.end': 'Month-End completed',
    'month.end.conflict': 'Month-End conflict recorded',
    'income.default.update': 'Default income updated',
  };
  if (special.containsKey(normalized)) return special[normalized]!;
  final parts = normalized.split('.');
  if (parts.first == 'vault' && parts.length > 1) {
    final movement = switch (parts[1]) {
      'deposit' => 'Savings deposited',
      'withdrawal' => 'Savings withdrawn',
      'reversal' => 'Savings transfer reversed',
      'sweep' => 'Monthly savings added',
      'opening' => 'Savings opening balance',
      _ => 'Savings ${_sentence(parts[1]).toLowerCase()}',
    };
    return parts.last == 'update' ? '$movement updated' : movement;
  }
  const verbs = {
    'create': 'added',
    'update': 'updated',
    'delete': 'deleted',
  };
  if (parts.length == 2 && verbs.containsKey(parts.last)) {
    return '${auditObjectLabel(parts.first)} ${verbs[parts.last]}';
  }
  if (parts.length == 3 && parts[1] == 'move') {
    return '${auditObjectLabel(parts.first)} moved ${parts.last == 'out' ? 'out' : 'in'}';
  }
  return _sentence(action.replaceAll('.', ' ').replaceAll('_', ' '));
}

String _sentence(String value) {
  final text = _label(value).trim();
  return text.isEmpty
      ? 'Unknown'
      : '${text[0].toUpperCase()}${text.substring(1)}';
}

/// Prefer the name saved with this event, including deleted/renamed records.
/// Never substitute a current record or guess a name from its numeric ID.
String auditObjectName(AuditEvent event) {
  for (final raw in [event.newValue, event.previousValue]) {
    if (raw == null) continue;
    try {
      final data = jsonDecode(raw);
      if (data is! Map) continue;
      for (final field in ['title', 'name']) {
        final value = data[field];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    } on FormatException {
      // Legacy free text is preserved in the value section.
    }
  }
  return auditObjectLabel(event.objectType);
}

/// Presentation of one original field. Comparisons never write to evidence.
class AuditFieldChange {
  const AuditFieldChange(
      {required this.key,
      required this.label,
      required this.before,
      required this.after,
      required this.changed,
      required this.section});
  final String key, label, before, after, section;
  final bool changed;
}

Map<String, Object?> _auditSnapshot(String? raw) {
  if (raw == null || raw == 'null') return {};
  try {
    final value = jsonDecode(raw);
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return {'recordedValue': value};
  } on FormatException {
    return {'recordedValue': raw};
  }
}

Object? _orderedAuditValue(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((e) => e.toString()).toList()..sort();
    return {for (final key in keys) key: _orderedAuditValue(value[key])};
  }
  if (value is List) return value.map(_orderedAuditValue).toList();
  return value;
}

bool _hasAuditValue(Object? value) =>
    value != null &&
    value != '' &&
    !(value is Iterable && value.isEmpty) &&
    !(value is Map && value.isEmpty);

String _auditFieldLabel(String key) =>
    const {
      'date': 'Expense date',
      'paidAt': 'Paid date',
      'yearMonth': 'Budget month',
      'financialProfileType': 'Financial profile',
      'isReimbursable': 'Reimbursable',
      'guiltLevel': 'Spending choice',
      'merchantName': 'Merchant',
      'paymentEvidenceJson': 'Payment evidence',
      'fxHistoryJson': 'Accounting value',
      'receiptTotalMinor': 'Receipt total',
      'categoryId': 'Category reference',
      'type': 'Type',
      'recordedValue': 'Recorded value',
    }[key] ??
    _sentence(key);

String _auditSection(String key) {
  if (_minor.contains(key) ||
      _major.contains(key) ||
      key.toLowerCase().contains('currency')) {
    return 'Money';
  }
  if (key == 'date' ||
      key.endsWith('At') ||
      key.endsWith('Date') ||
      key == 'yearMonth') {
    return 'Dates';
  }
  if ({
    'title',
    'name',
    'merchantName',
    'paymentMethod',
    'status',
    'financialProfileType',
    'isReimbursable',
    'guiltLevel',
    'notes',
    'tags',
    'type'
  }.contains(key)) {
    return 'Record details';
  }
  return 'Other details';
}

String? _auditEnum(String key, Object? value, String type) {
  List<String>? choices;
  if (type == 'Expense') {
    choices = switch (key) {
      'status' => ExpenseStatus.values.map((e) => e.name).toList(),
      'type' => ExpenseType.values.map((e) => e.name).toList(),
      'guiltLevel' => GuiltLevel.values.map((e) => e.name).toList(),
      _ => null,
    };
    if (key == 'financialProfileType' && value is String) {
      return const {
            'budget': 'Budget profile',
            'direct': 'Direct expense profile',
            'main': 'Main profile'
          }[value] ??
          '$value (needs review)';
    }
    if (key == 'paymentMethod' && value is String) {
      return expensePaymentMethods[value] ?? value;
    }
  } else if (type == 'SharedMember' && key == 'role') {
    choices = SharedMemberRole.values.map((e) => e.name).toList();
  } else if (type == 'IncomeSource') {
    if (key == 'type') {
      choices = IncomeSourceType.values.map((e) => e.name).toList();
    }
    if (key == 'frequency') {
      choices = IncomeFrequency.values.map((e) => e.name).toList();
    }
  }
  if (choices == null) return null;
  if (value is int) {
    return value >= 0 && value < choices.length
        ? _sentence(choices[value])
        : '$value (needs review)';
  }
  if (value is String) {
    return choices.contains(value) ? _sentence(value) : '$value (needs review)';
  }
  return null;
}

String _auditFieldValue(
    String key, Object? value, Map<String, Object?> snapshot, String type) {
  if (key == 'fxHistoryJson') return _fxSummary(value);
  if (key == 'paymentEvidenceJson') {
    try {
      final evidence = ExpenseEvidence.decode(value as String?);
      if (evidence == null) return 'Legacy · No recorded evidence';
      final details = [
        for (final document in evidence.documents)
          '${document.role == 'receipt' ? 'Receipt' : 'Payment proof'}: ${document.name}',
        if (evidence.cashAt != null)
          'Cash confirmed ${formatVaultTime(evidence.cashAt!)}'
      ];
      return details.isEmpty
          ? 'No payment documents recorded'
          : details.join(' · ');
    } catch (_) {
      return 'Evidence needs review';
    }
  }
  if (!_hasAuditValue(value)) return 'Not recorded';
  final friendly = _auditEnum(key, value, type);
  if (friendly != null) return friendly;
  if (key == 'date' ||
      key == 'paidAt' ||
      key.endsWith('Date') ||
      key.endsWith('At') ||
      key == 'timestamp') {
    DateTime? date;
    try {
      if (value is int) {
        date = value.abs() > 253402300799999
            ? DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
            : DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      } else if (value is String) {
        date = DateTime.tryParse(value);
      }
      if (date != null && date.year >= 1 && date.year <= 9999) {
        final formatted = formatVaultTime(date);
        return key == 'date' || key == 'paidAt' || key.endsWith('Date')
            ? formatted.split(',').first
            : formatted;
      }
    } on ArgumentError {
      return '$value (date needs review)';
    }
    return '$value (date needs review)';
  }
  // Original expense amounts belong to the original currency, even when a
  // separate context currency is recorded. Never invent a conversion here.
  final rawCurrency = type == 'Expense' && key == 'amount'
      ? snapshot['currency']
      : snapshot['accountingCurrency'] ??
          snapshot['contextCurrency'] ??
          snapshot['currency'];
  final currency = CurrencyCode.tryParse(rawCurrency?.toString());
  if (_minor.contains(key) && value is int && currency == null) {
    return '$value ${rawCurrency == null ? '(original minor units; currency not recorded)' : '${rawCurrency.toString().toUpperCase()} (original minor units)'}';
  }
  if (key == 'tags' && value is List) {
    return value.map((e) => e.toString()).join(', ');
  }
  return _describe(value, currency, key);
}

List<AuditFieldChange> auditFieldChanges(AuditEvent event) {
  final before = _auditSnapshot(event.previousValue),
      after = _auditSnapshot(event.newValue);
  final keys =
      {...before.keys, ...after.keys}.where((key) => !_technicalField(key));
  return [
    for (final key in keys)
      if (_hasAuditValue(before[key]) || _hasAuditValue(after[key]))
        AuditFieldChange(
            key: key,
            label: _auditFieldLabel(key),
            before: before.containsKey(key)
                ? _auditFieldValue(key, before[key], before, event.objectType)
                : 'Not recorded',
            after: after.containsKey(key)
                ? _auditFieldValue(key, after[key], after, event.objectType)
                : 'Removed',
            changed: jsonEncode(_orderedAuditValue(before[key])) !=
                    jsonEncode(_orderedAuditValue(after[key])) ||
                _auditFieldValue(key, before[key], before, event.objectType) !=
                    _auditFieldValue(key, after[key], after, event.objectType),
            section: _auditSection(key)),
  ];
}

/// Only a recorded, valid original amount may become a card headline.
String? auditHeadlineAmount(AuditEvent event) {
  final snapshot = _auditSnapshot(
      event.newValue == null || event.newValue == 'null'
          ? event.previousValue
          : event.newValue);
  for (final key in ['amount', 'amountMinor', 'allocation', 'totalMinor']) {
    final value = snapshot[key];
    if (value is! int || value.abs() > 9007199254740991) continue;
    final formatted = _auditFieldValue(key, value, snapshot, event.objectType);
    if (!formatted.contains('original minor units') &&
        !formatted.contains('invalid')) {
      return formatted;
    }
  }
  return null;
}
