import 'package:json_annotation/json_annotation.dart';

part 'daily_stats.g.dart';

@JsonSerializable()
class DailyStats {
  final int totalBreaks;
  final int totalExercises;
  final int totalMinutesActive;
  final DateTime date;

  DailyStats({
    this.totalBreaks = 0,
    this.totalExercises = 0,
    this.totalMinutesActive = 0,
    required this.date,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DailyStatsToJson(this);

  DailyStats copyWith({
    int? totalBreaks,
    int? totalExercises,
    int? totalMinutesActive,
    DateTime? date,
  }) {
    return DailyStats(
      totalBreaks: totalBreaks ?? this.totalBreaks,
      totalExercises: totalExercises ?? this.totalExercises,
      totalMinutesActive: totalMinutesActive ?? this.totalMinutesActive,
      date: date ?? this.date,
    );
  }
}
