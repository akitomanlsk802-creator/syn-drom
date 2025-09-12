import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:office_syndrome_helper/services/database_service.dart';
import 'package:office_syndrome_helper/models/user_settings.dart';
import 'package:office_syndrome_helper/models/notification_session.dart';
import 'package:office_syndrome_helper/models/session_status.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';

import 'database_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '.';
        }
        return null;
      });

  late DatabaseService service;
  late MockFlutterSecureStorage mockStorage;

  setUp(() async {
    DatabaseService.resetInstance();
    mockStorage = MockFlutterSecureStorage();
    when(mockStorage.read(key: anyNamed('key'))).thenAnswer(
      (_) => Future.value(
        '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32',
      ),
    );
    when(
      mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) => Future.value());

    service = DatabaseService.I;
    service.secureStorage = mockStorage;
    await service.initialize();
  });

  test('loadOrCreateDefaults returns valid settings', () async {
    final settings = await service.loadOrCreateDefaults();

    expect(settings.workingDays, isNotEmpty);
    expect(settings.workStartMinutes, lessThan(settings.workEndMinutes));
    expect(settings.intervalMinutes, isIn([30, 45, 60, 90, 120]));
    expect(settings.isValid, isTrue);
  });

  group('UserSettings operations', () {
    test('save and retrieve settings', () async {
      final settings = UserSettings(
        workingDays: [1, 2, 3, 4, 5],
        workStartMinutes: 540,
        workEndMinutes: 1020,
        intervalMinutes: 60,
      );

      await service.saveSettings(settings);
      final retrieved = await service.getSettings();

      expect(retrieved?.workingDays, equals(settings.workingDays));
      expect(retrieved?.workStartMinutes, equals(settings.workStartMinutes));
      expect(retrieved?.workEndMinutes, equals(settings.workEndMinutes));
      expect(retrieved?.intervalMinutes, equals(settings.intervalMinutes));
    });

    test('reject invalid settings', () async {
      final invalidSettings = UserSettings(
        workingDays: [], // Invalid: empty working days
        workStartMinutes: 540,
        workEndMinutes: 1020,
        intervalMinutes: 60,
      );

      expect(() => service.saveSettings(invalidSettings), throwsException);
    });
  });

  group('NotificationSession operations', () {
    test('save and retrieve session', () async {
      final session = NotificationSession(
        id: 'test_session',
        scheduledAt: DateTime.now(),
        status: SessionStatus.scheduled,
      );

      await service.putSession(session);
      final sessions = await service.listSessions();

      expect(sessions, contains(session));
    });

    test('list sessions with date range', () async {
      final now = DateTime.now();
      final session1 = NotificationSession(
        id: 'session1',
        scheduledAt: now,
        status: SessionStatus.scheduled,
      );
      final session2 = NotificationSession(
        id: 'session2',
        scheduledAt: now.add(const Duration(days: 1)),
        status: SessionStatus.scheduled,
      );

      await service.putSession(session1);
      await service.putSession(session2);

      final filtered = await service.listSessions(
        from: now,
        to: now.add(const Duration(hours: 1)),
      );

      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('session1'));
    });
  });

  group('DailyStats operations', () {
    test('upsert and retrieve stats', () async {
      final stats = DailyStats(
        dateLocalYmd: '2025-09-10',
        completed: 5,
        snoozed: 2,
        skipped: 1,
      );

      await service.upsertDailyStats(stats);
      final retrieved = await service.getDailyStats('2025-09-10');

      expect(retrieved?.completed, equals(stats.completed));
      expect(retrieved?.snoozed, equals(stats.snoozed));
      expect(retrieved?.skipped, equals(stats.skipped));
    });
  });
}
