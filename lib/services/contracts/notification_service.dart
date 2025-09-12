abstract class INotificationService {
  /// Handles snoozing a notification by scheduling a new one 15 minutes later
  Future<bool> handleSnooze(String sessionId);

  /// Get the next scheduled notification time
  DateTime? getNextScheduledTime();

  /// Schedule a notification to be shown at a specific time
  Future<void> scheduleNotification(DateTime scheduledTime);

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications();

  /// Cancel a specific notification by id
  Future<void> cancelNotification(String id);
}
