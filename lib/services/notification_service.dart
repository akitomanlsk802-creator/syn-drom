import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'contracts/i_notification_service.dart';

class NotificationService implements INotificationService {
  static final NotificationService I = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('app_icon');
    const darwinSettings = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );

    // Set up notification channel for Android
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'office_syndrome_helper_channel',
            'Exercise Reminders',
            description: 'Notifications for exercise reminders',
            importance: Importance.high,
          ),
        );

    _isInitialized = true;
  }

  @override
  Future<void> scheduleAt(DateTime when, {required String id}) async {
    final scheduledDate = tz.TZDateTime.from(when, tz.local);

    await _notifications.zonedSchedule(
      id.hashCode,
      'Time to Exercise',
      'Take a break and do some exercises',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'office_syndrome_helper_channel',
          'Exercise Reminders',
          channelDescription: 'Notifications for exercise reminders',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Exercise Time',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> showNow() async {
    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'office_syndrome_helper_channel',
          'Exercise Reminders',
          channelDescription: 'Notifications for exercise reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  @override
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  @override
  DateTime? getNextScheduledTime() {
    // TODO: Implement this method to return the next scheduled notification time
    // For now return null as it's not critical for the core functionality
    return null;
  }

  @override
  Future<void> onSettingsChanged() async {
    await cancelAll();
    // TODO: Reschedule notifications based on new settings
    // This will be implemented by notification controller
  }
}
