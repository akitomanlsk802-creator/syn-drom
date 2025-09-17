import 'dart:convert';

class DailyStats {
  final String ymd; // "YYYY-MM-DD"
  final int scheduled;
  final int completed;
  final int snoozed;
  final int skipped;

  const DailyStats({
    required this.ymd,
    required this.scheduled,
    required this.completed,
    required this.snoozed,
    required this.skipped,
  });

  DailyStats add({
    int scheduled = 0,
    int completed = 0,
    int snoozed = 0,
    int skipped = 0,
  }) {
    return DailyStats(
      ymd: ymd,
      scheduled: this.scheduled + scheduled,
      completed: this.completed + completed,
      snoozed: this.snoozed + snoozed,
      skipped: this.skipped + skipped,
    );
  }

  double get successRate {
    final denom = scheduled == 0 ? 1 : scheduled;
    return completed / denom;
  }

  Map<String, dynamic> toMap() => {
    'ymd': ymd,
    'scheduled': scheduled,
    'completed': completed,
    'snoozed': snoozed,
    'skipped': skipped,
  };

  factory DailyStats.fromMap(Map<String, dynamic> map) => DailyStats(
    ymd: map['ymd'] as String,
    scheduled: map['scheduled'] as int? ?? 0,
    completed: map['completed'] as int? ?? 0,
    snoozed: map['snoozed'] as int? ?? 0,
    skipped: map['skipped'] as int? ?? 0,
  );

  String toJson() => jsonEncode(toMap());
  factory DailyStats.fromJson(String src) =>
      DailyStats.fromMap(jsonDecode(src) as Map<String, dynamic>);
}
