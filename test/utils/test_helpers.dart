import 'package:flutter_test/flutter_test.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';

// Helper function to verify DailyStats matches
void verifyDailyStats(
  DailyStats captured, {
  required String dateLocalYmd,
  int completed = 0,
  int snoozed = 0,
  int skipped = 0,
}) {
  expect(captured.dateLocalYmd, dateLocalYmd);
  expect(captured.completed, completed);
  expect(captured.snoozed, snoozed);
  expect(captured.skipped, skipped);
}

// Helper function to create DailyStats for tests
DailyStats createTestStats({
  String? dateLocalYmd,
  int completed = 0,
  int snoozed = 0,
  int skipped = 0,
}) => DailyStats(
  dateLocalYmd: dateLocalYmd ?? DateTime.now().toIso8601String().split('T')[0],
  completed: completed,
  snoozed: snoozed,
  skipped: skipped,
);
