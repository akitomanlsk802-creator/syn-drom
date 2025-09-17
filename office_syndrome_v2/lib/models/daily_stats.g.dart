// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyStats _$DailyStatsFromJson(Map<String, dynamic> json) => DailyStats(
  totalBreaks: (json['totalBreaks'] as num?)?.toInt() ?? 0,
  totalExercises: (json['totalExercises'] as num?)?.toInt() ?? 0,
  totalMinutesActive: (json['totalMinutesActive'] as num?)?.toInt() ?? 0,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$DailyStatsToJson(DailyStats instance) =>
    <String, dynamic>{
      'totalBreaks': instance.totalBreaks,
      'totalExercises': instance.totalExercises,
      'totalMinutesActive': instance.totalMinutesActive,
      'date': instance.date.toIso8601String(),
    };
