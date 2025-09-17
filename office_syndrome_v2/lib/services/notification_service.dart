import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_session.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notifications;
  List<NotificationSession> _activeSessions = [];

  NotificationService({required this.notifications});

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await notifications.initialize(initSettings);
  }

  Future<void> scheduleNotification({
    required DateTime scheduledTime,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'office_syndrome_channel',
      'Office Syndrome Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    await notifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> startSession(DateTime startTime, DateTime endTime) async {
    final session = NotificationSession(startTime: startTime, endTime: endTime);
    _activeSessions.add(session);

    // Schedule initial notification
    await scheduleNotification(
      scheduledTime: startTime,
      title: 'Office Syndrome Prevention',
      body: 'Time to take a break and do some exercises!',
    );
  }

  void stopSession(DateTime sessionStartTime) {
    _activeSessions.removeWhere(
      (session) => session.startTime == sessionStartTime,
    );
    // Cancel related notifications if needed
  }

  List<NotificationSession> getActiveSessions() {
    return List.unmodifiable(_activeSessions);
  }
}
