import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:office_syndrome_v2/services/user_settings_service.dart';
import 'package:office_syndrome_v2/services/notification_service.dart';
import 'package:office_syndrome_v2/services/stats_service.dart';
import 'package:office_syndrome_v2/models/user_settings.dart';
import 'package:office_syndrome_v2/models/daily_stats.dart';

@GenerateNiceMocks([
  MockSpec<SharedPreferences>(),
  MockSpec<FlutterLocalNotificationsPlugin>(),
])
import 'services_integration_test.mocks.dart';

void main() {
  late UserSettingsService userSettingsService;
  late NotificationService notificationService;
  late StatsService statsService;
  late MockSharedPreferences mockSharedPreferences;
  late MockFlutterLocalNotificationsPlugin mockNotifications;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockNotifications = MockFlutterLocalNotificationsPlugin();

    userSettingsService = UserSettingsService(
      sharedPreferences: mockSharedPreferences,
    );
    notificationService = NotificationService(notifications: mockNotifications);
    statsService = StatsService(sharedPreferences: mockSharedPreferences);
  });

  group('Services Integration', () {
    test('should handle full notification workflow', () async {
      // 1. Save user settings
      final settings = UserSettings(
        notificationEnabled: true,
        notificationInterval: 30,
        workStartTime: DateTime(2025, 9, 17, 9, 0),
        workEndTime: DateTime(2025, 9, 17, 17, 0),
      );
      when(
        mockSharedPreferences.setString(any, any),
      ).thenAnswer((_) => Future.value(true));
      await userSettingsService.saveSettings(settings);

      // 2. Initialize notification service
      when(
        mockNotifications.initialize(any),
      ).thenAnswer((_) => Future.value(true));
      await notificationService.initialize();

      // 3. Start notification session
      when(
        mockNotifications.show(any, any, any, any),
      ).thenAnswer((_) => Future.value());
      await notificationService.startSession(
        settings.workStartTime,
        settings.workEndTime,
      );

      // 4. Record stats
      final stats = DailyStats(
        date: DateTime(2025, 9, 17),
        totalBreaks: 1,
        totalExercises: 2,
        totalMinutesActive: 5,
      );
      await statsService.saveDailyStats(DateTime(2025, 9, 17), stats);

      // 5. Load and verify all data
      when(mockSharedPreferences.getString(any)).thenReturn(
        '{"notificationEnabled":true,"notificationInterval":30,'
        '"workStartTime":"2025-09-17T09:00:00.000",'
        '"workEndTime":"2025-09-17T17:00:00.000"}',
      );
      final loadedSettings = await userSettingsService.loadSettings();
      expect(loadedSettings.notificationEnabled, true);
      expect(loadedSettings.notificationInterval, 30);

      final activeSessions = notificationService.getActiveSessions();
      expect(activeSessions.length, 1);
      expect(activeSessions.first.startTime, settings.workStartTime);
      expect(activeSessions.first.endTime, settings.workEndTime);

      when(mockSharedPreferences.getString(any)).thenReturn(
        '{"totalBreaks":1,"totalExercises":2,"totalMinutesActive":5,'
        '"date":"2025-09-17T00:00:00.000"}',
      );
      final loadedStats = await statsService.loadDailyStats(
        DateTime(2025, 9, 17),
      );
      expect(loadedStats?.totalBreaks, 1);
      expect(loadedStats?.totalExercises, 2);
      expect(loadedStats?.totalMinutesActive, 5);
    });
  });
}
