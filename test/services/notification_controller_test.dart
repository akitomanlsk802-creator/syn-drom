import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:office_syndrome_helper/models/user_settings.dart';
import 'package:office_syndrome_helper/services/notification_controller.dart';
import 'package:office_syndrome_helper/services/contracts/i_notification_service.dart';
import 'package:office_syndrome_helper/services/contracts/i_database_service.dart';
import 'package:office_syndrome_helper/models/notification_session.dart';
import 'package:office_syndrome_helper/models/session_status.dart';

class MockNotificationService extends Mock implements INotificationService {}

class MockDatabaseService extends Mock implements IDatabaseService {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      NotificationSession(
        id: 'dummy',
        scheduledAt: DateTime(2025),
        status: SessionStatus.scheduled,
      ),
    );
  });

  late NotificationController controller;
  late MockNotificationService notif;
  late MockDatabaseService db;
  late UserSettings settings;

  setUp(() async {
    notif = MockNotificationService();
    db = MockDatabaseService();
    controller = NotificationController(
      notificationService: notif,
      databaseService: db,
    );

    settings = UserSettings(
      workingDays: [1, 2, 3, 4, 5], // Mon-Fri
      workStartMinutes: 9 * 60, // 9:00
      workEndMinutes: 17 * 60, // 17:00
      intervalMinutes: 60,
      breakPeriods: [
        {'startMin': 12 * 60, 'endMin': 13 * 60}, // 12:00-13:00
      ],
    );

    // Set up common mock responses
    when(() => db.getSettings()).thenAnswer((_) async => settings);
    when(() => notif.initialize()).thenAnswer((_) async {});
    when(() => notif.cancelAll()).thenAnswer((_) async {});
  });

  group('Next Notification Time Calculation', () {
    test('skips break period', () async {
      when(() => db.getSettings()).thenAnswer((_) async => settings);

      final now = DateTime(2025, 9, 10, 11, 55); // 11:55 AM
      final next = await controller.calculateNextNotificationTime(
        now,
        settings,
      );

      expect(next?.hour, equals(13));
      expect(next?.minute, equals(1));
    });

    test('skips non-working days', () async {
      final friday = DateTime(2025, 9, 12, 16, 55); // Friday 16:55
      final next = await controller.calculateNextNotificationTime(
        friday,
        settings,
      );

      expect(next?.weekday, equals(1)); // Should be Monday
      expect(next?.hour, equals(9));
      expect(next?.minute, equals(0));
    });

    test('skips outside working hours', () async {
      final evening = DateTime(2025, 9, 10, 17, 30); // 17:30
      final next = await controller.calculateNextNotificationTime(
        evening,
        settings,
      );

      expect(next?.day, equals(11)); // Next day
      expect(next?.hour, equals(9));
      expect(next?.minute, equals(0));
    });
  });

  group('Settings Changes', () {
    test('reschedules on settings change', () async {
      final mockSession = NotificationSession(
        id: 'old_session',
        scheduledAt: DateTime(2025, 9, 10, 11, 0),
        status: SessionStatus.scheduled,
      );

      when(() => db.listSessions()).thenAnswer((_) async => [mockSession]);
      when(() => db.putSession(any())).thenAnswer((_) async {});
      when(
        () => notif.scheduleAt(any<DateTime>(), id: any(named: 'id')),
      ).thenAnswer((_) async {});

      await controller.onSettingsChanged();

      verify(() => notif.cancelAll()).called(1);
      verify(
        () => notif.scheduleAt(any<DateTime>(), id: any(named: 'id')),
      ).called(1);
      verify(() => db.putSession(any())).called(1);
    });
  });

  group('Snooze Handling', () {
    test('limits snooze count', () async {
      const sessionId = 'test_session';
      final sessions = [
        NotificationSession(
          id: sessionId,
          scheduledAt: DateTime(2025, 9, 10, 10, 0),
          status: SessionStatus.shown,
          snoozeCount: 0,
        ),
        NotificationSession(
          id: sessionId,
          scheduledAt: DateTime(2025, 9, 10, 10, 5),
          status: SessionStatus.snoozed,
          snoozeCount: 1,
        ),
      ];

      when(() => db.listSessions()).thenAnswer((_) async => sessions);
      when(() => db.putSession(any())).thenAnswer((_) async {});
      when(
        () => notif.scheduleAt(any<DateTime>(), id: any(named: 'id')),
      ).thenAnswer((_) async {});

      // First snooze should work
      expect(await controller.handleSnooze(sessionId), isTrue);

      verify(() => db.putSession(any())).called(1);
      verify(
        () => notif.scheduleAt(any<DateTime>(), id: any(named: 'id')),
      ).called(1);
    });
  });
}
