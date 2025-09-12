import '../../models/daily_stats.dart';
import '../../models/user_settings.dart';
import '../../models/notification_session.dart';

abstract class IDatabaseService {
  Future<DailyStats?> getTodayStats();
  Future<UserSettings?> getSettings();
  Future<void> putSession(NotificationSession session);
  Future<List<NotificationSession>> listSessions();
  Future<UserSettings> loadOrCreateDefaults();
}
