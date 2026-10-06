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

  Future<void> init() async {
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
    await _plugin.cancel(id: id);
  }
}
