import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:office_syndrome_helper/models/user_settings.dart';
import 'package:office_syndrome_helper/features/settings/controllers/settings_controller.dart';
import 'package:office_syndrome_helper/features/settings/presentation/pages/settings_page.dart';
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
    
    testSettings = UserSettings(
      workStartMinutes: 9 * 60,
      workEndMinutes: 17 * 60,
      intervalMinutes: 60,
      workingDays: [1, 2, 3, 4, 5],
      selectedPainPoints: ['neck'],
    );

    when(mockDatabaseService.getUserSettings())
        .thenAnswer((_) async => testSettings);

    controller = SettingsController(
      databaseService: mockDatabaseService,
      notificationService: mockNotificationService,
    );

    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('SettingsPage loads existing settings', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: SettingsPage()),
    );

    // Initial loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let settings load
    await tester.pumpAndSettle();

    // Verify initial values
    expect(find.text('09:00'), findsOneWidget); // Work start time
    expect(find.text('17:00'), findsOneWidget); // Work end time
    expect(find.text('1 ชั่วโมง'), findsOneWidget); // 60 min interval
  });

  testWidgets('SettingsPage shows validation errors', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(home: SettingsPage()),
    );
    await tester.pumpAndSettle();

    // Try to save invalid work hours
    await tester.enterText(
      find.widgetWithText(TextFormField, 'เวลาเริ่มงาน'),
      '18:00', // Start after end
    );
    
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();

    // Should show error
    expect(find.text('เวลาเริ่มต้องน้อยกว่าเวลาสิ้นสุด'), findsOneWidget);
  });

  testWidgets('SettingsPage saves valid settings', (tester) async {
    when(mockDatabaseService.saveUserSettings(any))
        .thenAnswer((_) async => true);
    when(mockNotificationService.onSettingsChanged())
        .thenAnswer((_) async {});

    await tester.pumpWidget(
      const GetMaterialApp(home: SettingsPage()),
    );
    await tester.pumpAndSettle();

    // Change interval
    await tester.tap(find.text('1 ชั่วโมง'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 นาที'));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();

    // Verify save and notification update
    verify(mockDatabaseService.saveUserSettings(any)).called(1);
    verify(mockNotificationService.onSettingsChanged()).called(1);
  });
});