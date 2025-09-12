import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:office_syndrome_helper/models/user_settings.dart';
import 'package:office_syndrome_helper/features/settings/controllers/settings_controller.dart';
import 'package:office_syndrome_helper/services/contracts/database_service.dart';
import 'package:office_syndrome_helper/services/notification_service.dart';

class MockDatabaseService extends Mock implements IDatabaseService {}
class MockNotificationService extends Mock implements INotificationService {}

void main() {
  late SettingsController controller;
  late MockDatabaseService mockDatabaseService;
  late MockNotificationService mockNotificationService;
  late UserSettings testSettings;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockNotificationService = MockNotificationService();
    controller = SettingsController(
      databaseService: mockDatabaseService,
      notificationService: mockNotificationService,
    );
    
    testSettings = UserSettings(
      workStartMinutes: 9 * 60,
      workEndMinutes: 17 * 60,
      intervalMinutes: 60,
      workingDays: [1, 2, 3, 4, 5],
      selectedPainPoints: ['neck'],
    );
  });

  group('Interval Validation', () {
    test('accepts valid intervals', () {
      expect(controller.isValidInterval(30), isTrue);
      expect(controller.isValidInterval(45), isTrue);
      expect(controller.isValidInterval(60), isTrue);
      expect(controller.isValidInterval(90), isTrue);
      expect(controller.isValidInterval(120), isTrue);
    });

    test('rejects invalid intervals', () {
      expect(controller.isValidInterval(15), isFalse);
      expect(controller.isValidInterval(75), isFalse);
      expect(controller.isValidInterval(0), isFalse);
      expect(controller.isValidInterval(-30), isFalse);
    });
  });

  group('Work Hours Validation', () {
    test('accepts valid work hours', () {
      expect(controller.isValidWorkHours(9 * 60, 17 * 60), isTrue);
      expect(controller.isValidWorkHours(0, 24 * 60), isTrue);
      expect(controller.isValidWorkHours(8 * 60, 8 * 60 + 30), isTrue);
    });

    test('rejects invalid work hours', () {
      expect(controller.isValidWorkHours(17 * 60, 9 * 60), isFalse); // end before start
      expect(controller.isValidWorkHours(-60, 17 * 60), isFalse); // negative start
      expect(controller.isValidWorkHours(9 * 60, 25 * 60), isFalse); // end after 24h
    });
  });

  group('Break Periods Validation', () {
    test('accepts non-overlapping periods', () {
      final periods = [
        (10 * 60, 11 * 60), // 10:00-11:00
        (12 * 60, 13 * 60), // 12:00-13:00
        (15 * 60, 16 * 60), // 15:00-16:00
      ];
      expect(controller.hasOverlap(periods), isFalse);
    });

    test('detects overlapping periods', () {
      final periods = [
        (10 * 60, 12 * 60), // 10:00-12:00
        (11 * 60, 13 * 60), // 11:00-13:00 (overlaps with first)
      ];
      expect(controller.hasOverlap(periods), isTrue);
    });
  });

  group('Pain Points Validation', () {
    test('accepts 1-3 pain points', () {
      expect(controller.isValidPainPoints(['neck']), isTrue);
      expect(controller.isValidPainPoints(['neck', 'back']), isTrue);
      expect(controller.isValidPainPoints(['neck', 'back', 'shoulder']), isTrue);
    });

    test('rejects empty or too many pain points', () {
      expect(controller.isValidPainPoints([]), isFalse);
      expect(
        controller.isValidPainPoints(['neck', 'back', 'shoulder', 'wrist']),
        isFalse,
      );
    });
  });

  group('Settings Save', () {
    test('saves valid settings and triggers notification update', () async {
      when(mockDatabaseService.saveUserSettings(any))
          .thenAnswer((_) async => true);
      when(mockNotificationService.onSettingsChanged())
          .thenAnswer((_) async {});

      final success = await controller.saveSettings(testSettings);

      expect(success, isTrue);
      verify(mockDatabaseService.saveUserSettings(testSettings)).called(1);
      verify(mockNotificationService.onSettingsChanged()).called(1);
    });

    test('rejects invalid settings', () async {
      // Invalid interval
      testSettings = testSettings.copyWith(intervalMinutes: 25);
      final success = await controller.saveSettings(testSettings);

      expect(success, isFalse);
      verifyNever(mockDatabaseService.saveUserSettings(any));
      verifyNever(mockNotificationService.onSettingsChanged());
    });
  });
});