import 'package:hive/hive.dart';

part 'daily_stats.g.dart';

@HiveType(typeId: 3)
class DailyStats extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  int completedSessions;

  @HiveField(2)
  int skippedSessions;

  @HiveField(3)
  int snoozedSessions;

  DailyStats({
    required this.date,
    this.completedSessions = 0,
    this.skippedSessions = 0,
    this.snoozedSessions = 0,
  });
}
