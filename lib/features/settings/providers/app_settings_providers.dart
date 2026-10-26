import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/app_settings.dart';

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository(IsarHelper.instance);
});

class AppSettingsRepository {
  final Isar _isar;

  AppSettingsRepository(this._isar);

  Stream<AppSettings?> watch() {
    return _isar.appSettings.watchObject(1, fireImmediately: true);
  }

  Future<AppSettings> getOrCreate() async {
    final existing = await _isar.appSettings.get(1);
    if (existing != null) return existing;
    final now = DateTime.now();
    final settings = AppSettings()
      ..id = 1
      ..transferToggle = false
      ..createdAt = now
      ..updatedAt = now;
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
    return settings;
  }

  Future<void> setTransferToggle(bool value) async {
    final settings = await getOrCreate();
    settings.transferToggle = value;
    settings.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
  }
}

final appSettingsProvider = StreamProvider<AppSettings?>((ref) {
  return ref.watch(appSettingsRepositoryProvider).watch();
});

final transferToggleProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).value?.transferToggle ?? false;
});
