import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:office_syndrome_v2/services/stats_service.dart';
import 'package:office_syndrome_v2/models/daily_stats.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
import 'stats_service_test.mocks.dart';

void main() {
  late StatsService statsService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    statsService = StatsService(sharedPreferences: mockSharedPreferences);
  });

  group('StatsService', () {
    test('should save daily stats', () async {
      // Arrange
      final date = DateTime(2025, 9, 17);
      final stats = DailyStats(
        date: date,
        totalBreaks: 5,
        totalExercises: 10,
        totalMinutesActive: 30,
      );
      when(
        mockSharedPreferences.setString(any, any),
      ).thenAnswer((_) => Future.value(true));

      // Act
      await statsService.saveDailyStats(date, stats);

      // Assert
      verify(mockSharedPreferences.setString(any, any)).called(1);
    });

    test('should load daily stats', () async {
      // Arrange
      final date = DateTime(2025, 9, 17);
      const statsJson =
          '{"totalBreaks":5,"totalExercises":10,'
          '"totalMinutesActive":30,"date":"2025-09-17T00:00:00.000"}';
      when(mockSharedPreferences.getString(any)).thenReturn(statsJson);

      // Act
      final stats = await statsService.loadDailyStats(date);

      // Assert
      expect(stats, isNotNull);
      expect(stats!.totalBreaks, 5);
      expect(stats.totalExercises, 10);
      expect(stats.totalMinutesActive, 30);
      expect(stats.date.year, 2025);
      expect(stats.date.month, 9);
      expect(stats.date.day, 17);
    });

    test('should handle missing stats', () async {
      // Arrange
      final date = DateTime(2025, 9, 17);
      when(mockSharedPreferences.getString(any)).thenReturn(null);

      // Act
      final stats = await statsService.loadDailyStats(date);

      // Assert
      expect(stats, isNull);
    });
  });
}
