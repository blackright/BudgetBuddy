import 'dart:convert';

import '../../../core/models/currency_code.dart';
import '../../../core/models/income_source.dart';
import '../../../core/services/filter_service.dart' show parseSearchAmount;
import '../../../core/services/profile_name.dart';

enum OnboardingStage {
  draft,
  coreCommitted,
  preparing,
  readyToFinish,
  completed
}

enum OnboardingStep {
  welcome,
  budgeting,
  profile,
  firstMonth,
  security,
  overview,
  finish
}

enum OnboardingOpeningChoice { unset, known, unknown }

enum OnboardingIncomeChoice { unset, sources, none }

enum OnboardingSecurityChoice { pending, notNow, configured }

/// A recoverable metadata error. Never includes persisted draft/secret content.
class OnboardingStateException implements Exception {
  const OnboardingStateException(this.code);
  final String code;
  @override
  String toString() => 'Onboarding progress needs review ($code).';
}

class OnboardingProfileDraft {
  const OnboardingProfileDraft({this.name = '', this.currency});
  final String name;
  final CurrencyCode? currency;
  Map<String, Object?> toJson() =>
      {'name': name, 'currency': currency?.name.toUpperCase()};
  static OnboardingProfileDraft read(Object? value) {
    final m = _object(value, ['name', 'currency']);
    return OnboardingProfileDraft(
        name: _string(m['name']), currency: _currency(m['currency']));
  }
}

class OnboardingOpeningDraft {
  const OnboardingOpeningDraft(
      {this.choice = OnboardingOpeningChoice.unset,
      this.amountText = '',
      this.minorUnits,
      this.currency});
  final OnboardingOpeningChoice choice;
  final String amountText;
  final int? minorUnits;
  final CurrencyCode? currency;
  Map<String, Object?> toJson() => {
        'choice': choice.name,
        'amountText': amountText,
        'minorUnits': minorUnits,
        'currency': currency?.name.toUpperCase()
      };
  static OnboardingOpeningDraft read(Object? value) {
    final m =
        _object(value, ['choice', 'amountText', 'minorUnits', 'currency']);
    return OnboardingOpeningDraft(
        choice: _enum(m['choice'], OnboardingOpeningChoice.values),
        amountText: _string(m['amountText']),
        minorUnits: _nullableInteger(m['minorUnits']),
        currency: _currency(m['currency']));
  }
}

class OnboardingSourceDraft {
  const OnboardingSourceDraft(
      {required this.sourceGuid,
      this.name = '',
      this.type = IncomeSourceType.other,
      this.frequency = IncomeFrequency.monthly,
      this.amountText = '',
      this.minorUnits,
      this.currency,
      this.startDate,
      this.endDate,
      this.notes});
  final String sourceGuid;
  final String name;
  final IncomeSourceType type;
  final IncomeFrequency frequency;
  final String amountText;
  final int? minorUnits;
  final CurrencyCode? currency;

  /// Date-only values preserve the user's calendar day, not a UTC conversion.
  final DateTime? startDate, endDate;
  final String? notes;
  Map<String, Object?> toJson() => {
        'sourceGuid': sourceGuid,
        'name': name,
        'type': type.name,
        'frequency': frequency.name,
        'amountText': amountText,
        'minorUnits': minorUnits,
        'currency': currency?.name.toUpperCase(),
        'startDate': _day(startDate),
        'endDate': _day(endDate),
        'notes': notes
      };
  static OnboardingSourceDraft read(Object? value) {
    final m = _object(value, [
      'sourceGuid',
      'name',
      'type',
      'frequency',
      'amountText',
      'minorUnits',
      'currency',
      'startDate',
      'endDate',
      'notes'
    ]);
    return OnboardingSourceDraft(
        sourceGuid: _string(m['sourceGuid']),
        name: _string(m['name']),
        type: _enum(m['type'], IncomeSourceType.values),
        frequency: _enum(m['frequency'], IncomeFrequency.values),
        amountText: _string(m['amountText']),
        minorUnits: _nullableInteger(m['minorUnits']),
        currency: _currency(m['currency']),
        startDate: _date(m['startDate']),
        endDate: _date(m['endDate']),
        notes: m['notes'] == null ? null : _string(m['notes']));
  }
}

class OnboardingCommitReference {
  OnboardingCommitReference(
      {required this.profileId,
      required this.budgetId,
      required this.budgetSyncGuid,
      required this.yearMonth,
      required this.revision,
      required this.digest,
      required Map<String, int> sourceIds})
      : sourceIds = Map.unmodifiable(sourceIds);
  final int profileId, budgetId, revision;
  final String budgetSyncGuid, yearMonth, digest;
  final Map<String, int> sourceIds;
  Map<String, Object?> toJson() => {
        'profileId': profileId,
        'budgetId': budgetId,
        'budgetSyncGuid': budgetSyncGuid,
        'yearMonth': yearMonth,
        'revision': revision,
        'digest': digest,
        'sourceIds': sourceIds
      };
  static OnboardingCommitReference read(Object? value) {
    final m = _object(value, [
      'profileId',
      'budgetId',
      'budgetSyncGuid',
      'yearMonth',
      'revision',
      'digest',
      'sourceIds'
    ]);
    final ids = m['sourceIds'];
    if (ids is! Map<String, dynamic>) {
      _invalid();
    }
    return OnboardingCommitReference(
        profileId: _integer(m['profileId']),
        budgetId: _integer(m['budgetId']),
        budgetSyncGuid: _string(m['budgetSyncGuid']),
        yearMonth: _string(m['yearMonth']),
        revision: _integer(m['revision']),
        digest: _string(m['digest']),
        sourceIds: ids.map((key, value) => MapEntry(key, _integer(value))));
  }
}

/// Local, typed metadata only. It neither saves finances nor grants access.
/// Invalid user text can remain in a draft; parsed monetary evidence, committed
/// references and completion states must satisfy the stronger invariants below.
class OnboardingState {
  OnboardingState(
      {required this.flowId,
      required this.revision,
      required this.createdAt,
      required this.updatedAt,
      this.stage = OnboardingStage.draft,
      this.step = OnboardingStep.welcome,
      this.yearMonth,
      this.profile = const OnboardingProfileDraft(),
      this.opening = const OnboardingOpeningDraft(),
      this.incomeChoice = OnboardingIncomeChoice.unset,
      List<OnboardingSourceDraft> sources = const [],
      this.committed,
      this.categoriesReady = false,
      this.directoryReady = false,
      this.securityChoice = OnboardingSecurityChoice.pending,
      this.amendmentDraftJson,
      this.completedAt})
      : sources = List.unmodifiable(sources);
  static const version = 1;
  static const flowVersion = 1;
  static const maxEncodedBytes = 256 * 1024;
  static const maxInteger = 9007199254740991;
  final String flowId;
  final int revision;
  final DateTime createdAt, updatedAt;
  final OnboardingStage stage;
  final OnboardingStep step;
  final String? yearMonth;
  final OnboardingProfileDraft profile;
  final OnboardingOpeningDraft opening;
  final OnboardingIncomeChoice incomeChoice;
  final List<OnboardingSourceDraft> sources;
  final OnboardingCommitReference? committed;
  final bool categoriesReady, directoryReady;

  /// Optional unfinished correction. Original committed evidence stays intact.
  /// Kept in the existing bounded local envelope; never a synced money row.
  final String? amendmentDraftJson;

  /// Records an enrollment choice, never authentication proof or permission.
  final OnboardingSecurityChoice securityChoice;
  final DateTime? completedAt;

  Map<String, Object?> _json() => {
        'version': version,
        'flowVersion': flowVersion,
        'flowId': flowId,
        'revision': revision,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'stage': stage.name,
        'step': step.name,
        'yearMonth': yearMonth,
        'profile': profile.toJson(),
        'opening': opening.toJson(),
        'incomeChoice': incomeChoice.name,
        'sources': sources.map((s) => s.toJson()).toList(),
        'committed': committed?.toJson(),
        'categoriesReady': categoriesReady,
        'directoryReady': directoryReady,
        'securityChoice': securityChoice.name,
        'completedAt': completedAt?.toUtc().toIso8601String(),
        if (amendmentDraftJson != null) 'amendmentDraftJson': amendmentDraftJson
      };

  String encode() {
    _validate();
    final text = jsonEncode(_json());
    _checkSize(text);
    return text;
  }

  static OnboardingState decode(String text) {
    _checkSize(text);
    // Bound nesting BEFORE jsonDecode so deeply nested corrupt input cannot
    // exhaust its parser stack. Brackets inside escaped strings do not count.
    var depth = 0, quoted = false, escaped = false;
    for (final char in text.codeUnits) {
      if (quoted) {
        if (escaped) {
          escaped = false;
        } else if (char == 92) {
          escaped = true;
        } else if (char == 34) {
          quoted = false;
        }
      } else if (char == 34) {
        quoted = true;
      } else if (char == 123 || char == 91) {
        if (++depth > 16) {
          throw const OnboardingStateException('nesting');
        }
      } else if (char == 125 || char == 93) {
        depth--;
      }
    }
    try {
      final decoded = jsonDecode(text);
      final m = _object(decoded, [
        if (decoded is Map && decoded.containsKey('amendmentDraftJson'))
          'amendmentDraftJson',
        'version',
        'flowVersion',
        'flowId',
        'revision',
        'createdAt',
        'updatedAt',
        'stage',
        'step',
        'yearMonth',
        'profile',
        'opening',
        'incomeChoice',
        'sources',
        'committed',
        'categoriesReady',
        'directoryReady',
        'securityChoice',
        'completedAt'
      ]);
      if (m['version'] != version ||
          m['flowVersion'] != flowVersion ||
          m['version'] is! int ||
          m['flowVersion'] is! int) {
        throw const OnboardingStateException('unsupportedVersion');
      }
      final rows = m['sources'];
      if (rows is! List) {
        _invalid();
      }
      final state = OnboardingState(
          flowId: _string(m['flowId']),
          revision: _integer(m['revision']),
          createdAt: _timestamp(m['createdAt']),
          updatedAt: _timestamp(m['updatedAt']),
          stage: _enum(m['stage'], OnboardingStage.values),
          step: _enum(m['step'], OnboardingStep.values),
          yearMonth: m['yearMonth'] == null ? null : _string(m['yearMonth']),
          profile: OnboardingProfileDraft.read(m['profile']),
          opening: OnboardingOpeningDraft.read(m['opening']),
          incomeChoice: _enum(m['incomeChoice'], OnboardingIncomeChoice.values),
          sources: rows.map(OnboardingSourceDraft.read).toList(),
          committed: m['committed'] == null
              ? null
              : OnboardingCommitReference.read(m['committed']),
          categoriesReady: _boolean(m['categoriesReady']),
          directoryReady: _boolean(m['directoryReady']),
          securityChoice:
              _enum(m['securityChoice'], OnboardingSecurityChoice.values),
          amendmentDraftJson: m['amendmentDraftJson'] == null
              ? null
              : _string(m['amendmentDraftJson']),
          completedAt:
              m['completedAt'] == null ? null : _timestamp(m['completedAt']));
      state._validate();
      return state;
    } on OnboardingStateException {
      rethrow;
    } on FormatException {
      throw const OnboardingStateException('malformed');
    }
  }

  void _validate() {
    if (amendmentDraftJson != null) {
      if (stage == OnboardingStage.draft ||
          stage == OnboardingStage.completed) {
        _invalid();
      }
      // A nested draft rejects its own amendment before any further recursion.
      final edit = OnboardingState.decode(amendmentDraftJson!);
      if (edit.stage != OnboardingStage.draft ||
          edit.flowId != flowId ||
          edit.revision != revision ||
          !edit.createdAt.isAtSameMomentAs(createdAt) ||
          edit.profile.currency != profile.currency) {
        _invalid();
      }
    }
    if (!_identifier(flowId) ||
        revision < 0 ||
        revision > maxInteger ||
        updatedAt.isBefore(createdAt) ||
        (yearMonth != null && !_month(yearMonth!))) {
      _invalid();
    }
    final seen = <String>{};
    _amount(opening.amountText, opening.minorUnits, opening.currency);
    if (opening.choice != OnboardingOpeningChoice.known &&
        (opening.amountText.isNotEmpty ||
            opening.minorUnits != null ||
            opening.currency != null)) {
      _invalid();
    }
    if (opening.currency != null && opening.currency != profile.currency) {
      _invalid();
    }
    if (incomeChoice != OnboardingIncomeChoice.sources && sources.isNotEmpty) {
      _invalid();
    }
    for (final source in sources) {
      if (!_identifier(source.sourceGuid) ||
          !seen.add(source.sourceGuid) ||
          (source.currency != null && source.currency != profile.currency)) {
        _invalid();
      }
      _amount(source.amountText, source.minorUnits, source.currency);
      for (final date in [source.startDate, source.endDate]) {
        if (date != null &&
            (date.hour != 0 ||
                date.minute != 0 ||
                date.second != 0 ||
                date.millisecond != 0 ||
                date.microsecond != 0 ||
                date.year < 1 ||
                date.year > 9999)) {
          _invalid();
        }
      }
      if (source.startDate != null &&
          source.endDate != null &&
          _day(source.endDate)!.compareTo(_day(source.startDate)!) < 0 &&
          (stage != OnboardingStage.draft || source.minorUnits != null)) {
        _invalid();
      }
    }
    if (stage == OnboardingStage.draft) {
      if (committed != null ||
          categoriesReady ||
          directoryReady ||
          securityChoice != OnboardingSecurityChoice.pending ||
          completedAt != null) {
        _invalid();
      }
      return;
    }
    final ref = committed;
    if (ref == null ||
        !_positiveId(ref.profileId) ||
        !_positiveId(ref.budgetId) ||
        !_identifier(ref.budgetSyncGuid) ||
        !_month(ref.yearMonth) ||
        ref.yearMonth != yearMonth ||
        ref.revision < 0 ||
        ref.revision > revision ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(ref.digest)) {
      _invalid();
    }
    if (ref.sourceIds.values.toSet().length != ref.sourceIds.length) {
      _invalid();
    }
    for (final entry in ref.sourceIds.entries) {
      if (!_identifier(entry.key) || !_positiveId(entry.value)) {
        _invalid();
      }
    }
    if (stage == OnboardingStage.completed) {
      if (completedAt == null ||
          completedAt!.isBefore(createdAt) ||
          completedAt!.isAfter(updatedAt) ||
          step != OnboardingStep.finish ||
          !categoriesReady ||
          !directoryReady ||
          securityChoice == OnboardingSecurityChoice.pending ||
          profile.name.isNotEmpty ||
          profile.currency != null ||
          opening.choice != OnboardingOpeningChoice.unset ||
          incomeChoice != OnboardingIncomeChoice.unset ||
          sources.isNotEmpty) {
        _invalid();
      }
    } else {
      if (completedAt != null ||
          profileNameProblem(profile.name) != null ||
          profile.currency == null ||
          opening.choice == OnboardingOpeningChoice.unset ||
          (opening.choice == OnboardingOpeningChoice.known &&
              opening.minorUnits == null) ||
          incomeChoice == OnboardingIncomeChoice.unset ||
          (incomeChoice == OnboardingIncomeChoice.sources && sources.isEmpty) ||
          ref.sourceIds.length != sources.length ||
          sources.any((s) =>
              !ref.sourceIds.containsKey(s.sourceGuid) ||
              s.name.trim().isEmpty ||
              s.minorUnits == null ||
              s.currency == null)) {
        _invalid();
      }
      if (stage == OnboardingStage.readyToFinish &&
          (!categoriesReady ||
              !directoryReady ||
              securityChoice == OnboardingSecurityChoice.pending)) {
        _invalid();
      }
    }
  }
}

Never _invalid() => throw const OnboardingStateException('invalid');
void _checkSize(String text) {
  if (text.length > OnboardingState.maxEncodedBytes ||
      utf8.encode(text).length > OnboardingState.maxEncodedBytes) {
    throw const OnboardingStateException('oversized');
  }
}

Map<String, dynamic> _object(Object? value, List<String> keys) {
  if (value is! Map<String, dynamic> ||
      value.length != keys.length ||
      keys.any((key) => !value.containsKey(key))) {
    _invalid();
  }
  return value;
}

String _string(Object? value) {
  if (value is! String) {
    _invalid();
  }
  return value;
}

int _integer(Object? value) {
  if (value is! int) {
    _invalid();
  }
  return value;
}

int? _nullableInteger(Object? value) => value == null ? null : _integer(value);
bool _boolean(Object? value) {
  if (value is! bool) {
    _invalid();
  }
  return value;
}

T _enum<T extends Enum>(Object? value, List<T> values) {
  for (final item in values) {
    if (item.name == value) return item;
  }
  _invalid();
}

CurrencyCode? _currency(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    _invalid();
  }
  final code = CurrencyCode.tryParse(value);
  if (code == null || code.name.toUpperCase() != value) {
    _invalid();
  }
  return code;
}

bool _identifier(String value) =>
    RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._:-]{0,127}$').hasMatch(value);
bool _positiveId(int id) => id > 0 && id <= OnboardingState.maxInteger;
bool _month(String value) {
  if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value)) return false;
  return int.parse(value.substring(0, 4)) > 0;
}

String? _day(DateTime? value) => value == null
    ? null
    : '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
DateTime? _date(Object? value) {
  if (value == null) return null;
  final text = _string(value);
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
    _invalid();
  }
  final date = DateTime.tryParse(text);
  if (date == null || date.year < 1 || _day(date) != text) {
    _invalid();
  }
  return date;
}

DateTime _timestamp(Object? value) {
  final text = _string(value);
  final date = DateTime.tryParse(text);
  if (date == null || !date.isUtc || date.toIso8601String() != text) {
    _invalid();
  }
  return date;
}

void _amount(String raw, int? minor, CurrencyCode? currency) {
  if (minor == null) return;
  if (minor < 0 || minor > OnboardingState.maxInteger || currency == null) {
    _invalid();
  }
  try {
    if (parseSearchAmount(raw, currency) != minor) {
      _invalid();
    }
  } on FormatException {
    _invalid();
  }
}
