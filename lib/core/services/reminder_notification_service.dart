import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'dart:io';

class ReminderNotificationService {
  static final ReminderNotificationService _instance =
      ReminderNotificationService._();
  factory ReminderNotificationService() => _instance;
  ReminderNotificationService._();

  bool get _isTest => Platform.environment.containsKey('FLUTTER_TEST');

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Future<void>? _initFuture;

  /// Wakes the plugin up the first time it is actually needed (lazy) and only
  /// once (idempotent), never blocking app startup.
  ///
  /// Android attaches the plugin's `context` only after the engine is running,
  /// so initializing eagerly in `main()` can hit a null context and throw a
  /// `NullPointerException`. Running here—when a reminder is first scheduled or
  /// queried—guarantees the context exists. Any failure is logged and swallowed
  /// so notifications can never stop the app from opening.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (_isTest) {
      _initialized = true;
      return;
    }
    final inFlight = _initFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    final future = _init();
    _initFuture = future;
    try {
      await future;
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint(
          'ReminderNotificationService init failed: $error\n$stackTrace');
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _init() async {
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Background and foreground actions can be handled here or via background handlers.
      },
    );
  }

  Future<bool> requestPermissions() async {
    if (_isTest) return false;
    await ensureInitialized();
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool? granted =
        await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
    return granted ?? false;
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (_isTest) return;
    await ensureInitialized();
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'medical_reminders',
          'Medical Reminders',
          channelDescription: 'Reminders for following up on medical bills',
          importance: Importance.max,
          priority: Priority.high,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction('snooze_1d', 'Snooze 1 day'),
            AndroidNotificationAction('open', 'Open'),
          ],
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(int id) async {
    if (_isTest) return;
    await ensureInitialized();
    await _plugin.cancel(id: id);
  }
}
