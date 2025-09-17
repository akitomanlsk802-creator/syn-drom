import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:office_syndrome_v2/services/notification_service.dart';
import 'package:office_syndrome_v2/models/notification_session.dart';

@GenerateNiceMocks([MockSpec<FlutterLocalNotificationsPlugin>()])
import 'notification_service_test.mocks.dart';

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotifications;

  setUp(() {
    mockNotifications = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService(notifications: mockNotifications);
  });

  group('NotificationService', () {
    test('should initialize notifications', () async {
      // Arrange
      when(
        mockNotifications.initialize(any),
      ).thenAnswer((_) => Future.value(true));

      // Act
      await notificationService.initialize();

      // Assert
      verify(mockNotifications.initialize(any)).called(1);
    });

    test('should schedule notification', () async {
      // Arrange
      final scheduledTime = DateTime.now().add(Duration(minutes: 30));
      when(
        mockNotifications.show(any, any, any, any),
      ).thenAnswer((_) => Future.value());

      // Act
      await notificationService.scheduleNotification(
        scheduledTime: scheduledTime,
        title: 'Test Title',
        body: 'Test Body',
      );

      // Assert
      verify(mockNotifications.show(any, any, any, any)).called(1);
    });

    test('should start notification session', () async {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(hours: 8));
      when(
        mockNotifications.show(any, any, any, any),
      ).thenAnswer((_) => Future.value());

      // Act
      await notificationService.startSession(startTime, endTime);

      // Assert
      final sessions = notificationService.getActiveSessions();
      expect(sessions.length, 1);
      expect(sessions.first.startTime, startTime);
      expect(sessions.first.endTime, endTime);
      expect(sessions.first.isActive, true);
      verify(mockNotifications.show(any, any, any, any)).called(1);
    });

    test('should stop notification session', () async {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(hours: 8));
      await notificationService.startSession(startTime, endTime);

      // Act
      notificationService.stopSession(startTime);

      // Assert
      final sessions = notificationService.getActiveSessions();
      expect(sessions.length, 0);
    });
  });
}
