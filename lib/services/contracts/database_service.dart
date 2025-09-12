import '../../../models/daily_stats.dart';
import '../../../models/user_settings.dart';
import '../../../models/notification_session.dart';

abstract class IDatabaseService {
  /// Initialize the database
  Future<void> init();

  /// Update or insert daily statistics
  Future<void> upsertDailyStats(DailyStats stats);

  /// Get daily statistics for today
  Future<DailyStats?> getTodayStats();

  /// Get daily statistics for a specific date
  Future<DailyStats?> getDailyStats(String ymd);

  /// Get user settings
  Future<UserSettings?> getUserSettings();

  /// Update user settings
  Future<void> updateUserSettings(UserSettings settings);

  /// Save notification session
  Future<void> saveNotificationSession(NotificationSession session);

  /// Get notification session by id
  Future<NotificationSession?> getNotificationSession(String id);

  /// Delete notification session
  Future<void> deleteNotificationSession(String id);
}
