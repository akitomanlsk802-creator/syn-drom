import 'package:hive/hive.dart';

part 'daily_stats.g.dart';

@HiveType(typeId: 3)
class DailyStats {
  @HiveField(0)
  final String dateLocalYmd;

  @HiveField(1)
  final int completed;

  @HiveField(2)
  final int snoozed;

  @HiveField(3)
  final int skipped;

  DailyStats({
    required this.dateLocalYmd,
    this.completed = 0,
    this.snoozed = 0,
    this.skipped = 0,
  });
}
