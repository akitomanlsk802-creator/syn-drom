import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:office_syndrome_v2/services/user_settings_service.dart';
import 'package:office_syndrome_v2/models/user_settings.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
import 'user_settings_service_test.mocks.dart';

void main() {
  late UserSettingsService userSettingsService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    userSettingsService = UserSettingsService(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('UserSettingsService', () {
    test('should save settings', () async {
      // Arrange
      final settings = UserSettings(
        notificationEnabled: true,
        notificationInterval: 30,
        workStartTime: DateTime(2025, 1, 1, 9, 0),
        workEndTime: DateTime(2025, 1, 1, 17, 0),
      );
      when(
        mockSharedPreferences.setString(any, any),
      ).thenAnswer((_) => Future.value(true));

      // Act
      await userSettingsService.saveSettings(settings);

      // Assert
      verify(mockSharedPreferences.setString(any, any)).called(1);
    });

    test('should load settings', () async {
      // Arrange
      const settingsJson =
          '{"notificationEnabled":true,"notificationInterval":30,'
          '"workStartTime":"2025-01-01T09:00:00.000","workEndTime":"2025-01-01T17:00:00.000"}';
      when(mockSharedPreferences.getString(any)).thenReturn(settingsJson);

      // Act
      final settings = await userSettingsService.loadSettings();

      // Assert
      expect(settings.notificationEnabled, true);
      expect(settings.notificationInterval, 30);
      expect(settings.workStartTime.hour, 9);
      expect(settings.workEndTime.hour, 17);
    });

    test('should handle missing settings', () async {
      // Arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);

      // Act
      final settings = await userSettingsService.loadSettings();

      // Assert
      expect(settings, isNotNull);
      expect(settings.notificationEnabled, false); // Default value
    });
  });
}
