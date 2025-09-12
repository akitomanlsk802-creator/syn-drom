import '../../models/daily_stats.dart';

abstract class DatabaseService {
  Future<DailyStats?> getTodayStats();
  Future<void> updateDailyStats(DailyStats stats);
}
