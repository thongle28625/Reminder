import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance =
      NotificationService._internal();

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'task_channel',
    'Task Reminder',
    channelDescription: 'Nhắc nhở công việc',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const NotificationDetails _notificationDetails =
      NotificationDetails(
    android: _androidDetails,
  );

  Future<void> init() async {
    tz.initializeTimeZones();

    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

    const android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: android,
    );

    await notifications.initialize(
      settings,
    );

    final androidPlugin =
        notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleDate,
  }) async {
    if (scheduleDate.isBefore(
      DateTime.now(),
    )) {
      return;
    }

    final scheduledAt = tz.TZDateTime.from(
      scheduleDate,
      tz.local,
    );

    try {
      await notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (error) {
      if (error.message?.contains('exact alarm') != true) {
        rethrow;
      }

      await notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await notifications.cancel(id);
  }

  Future<void> updateNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleDate,
  }) async {
    await cancelNotification(id);

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduleDate: scheduleDate,
    );
  }
}
