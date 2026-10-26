import 'dart:async';

import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/features/security/repositories/lock_settings_store.dart';

/// A [LockSettingsStore] with no database behind it, for the widget tests.
///
/// The real store is an Isar collection, and a live Isar inside `testWidgets`
/// hangs in the fake-async zone (the reason the gate tests override every
/// stream). This double keeps the settings card testable without a database
/// while still driving the same watch/upsert/delete contract the card uses.
class InMemoryLockSettingsStore implements LockSettingsStore {
  final Map<String, LockSetting> _rows = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<LockSetting?> watch(String subjectKey) async* {
    yield _rows[subjectKey];
    await for (final _ in _changes.stream) {
      yield _rows[subjectKey];
    }
  }

  @override
  Future<LockSetting?> find(String subjectKey) async => _rows[subjectKey];

  @override
  Future<List<LockSetting>> all() async => _rows.values.toList();

  @override
  Future<void> upsert(LockSetting setting, {DateTime? at}) async {
    setting.updatedAt = at ?? DateTime.now();
    _rows[setting.subjectKey] = setting;
    _changes.add(null);
  }

  @override
  Future<void> delete(String subjectKey) async {
    if (_rows.remove(subjectKey) != null) _changes.add(null);
  }

  /// Releases the change stream once the test is done with the store.
  Future<void> dispose() => _changes.close();
}
