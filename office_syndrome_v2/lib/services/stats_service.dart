import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_stats.dart';

class StatsService {
  final SharedPreferences sharedPreferences;
  static const String _statsPrefix = 'daily_stats_';

  StatsService({required this.sharedPreferences});

  Future<void> saveDailyStats(DateTime date, DailyStats stats) async {
    final key = _getKey(date);
    final jsonString = jsonEncode(stats.toJson());
    await sharedPreferences.setString(key, jsonString);
  }

  Future<DailyStats?> loadDailyStats(DateTime date) async {
    final key = _getKey(date);
    final jsonString = sharedPreferences.getString(key);
    if (jsonString == null) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString);
      return DailyStats.fromJson(json);
    } catch (e) {
      print('Error loading stats: $e');
      return null;
    }
  }

  String _getKey(DateTime date) {
    return _statsPrefix + date.toIso8601String().split('T')[0];
  }
}
