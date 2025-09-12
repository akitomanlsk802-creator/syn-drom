import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:office_syndrome_helper/models/user_settings.dart';
import 'package:office_syndrome_helper/features/settings/controllers/settings_controller.dart';
import 'package:office_syndrome_helper/features/settings/presentation/pages/settings_page.dart';
import 'package:office_syndrome_helper/services/contracts/i_database_service.dart';
import 'package:office_syndrome_helper/services/contracts/i_notification_service.dart';

@GenerateMocks([IDatabaseService, INotificationService])
import 'settings_page_test.mocks.dart';

void main() {
  late SettingsController controller;
  late MockIDatabaseService mockDatabaseService;
  late MockINotificationService mockNotificationService;
  late UserSettings testSettings;

  setUp(() {
    mockDatabaseService = MockIDatabaseService();
    mockNotificationService = MockINotificationService();

    testSettings = UserSettings(
      workStartMinutes: 9 * 60,
      workEndMinutes: 17 * 60,
      intervalMinutes: 60,
      workingDays: [1, 2, 3, 4, 5],
      selectedPainPoints: ['neck'],
    );

    // Initial null state
    when(mockDatabaseService.getSettings()).thenAnswer((_) async => null);

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
    await tester.pumpWidget(const GetMaterialApp(home: SettingsPage()));
    await tester.pump();

    // Initial loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Update mock to return settings
    when(
      mockDatabaseService.getSettings(),
    ).thenAnswer((_) async => testSettings);
    controller.update();

    // Let settings load
    controller.settings.value = testSettings;
    await tester.pump();

    // Verify initial values
    expect(find.text('09:00'), findsOneWidget); // Work start time
    expect(find.text('17:00'), findsOneWidget); // Work end time
    expect(find.text('1 ชั่วโมง'), findsOneWidget); // 60 min interval
  });

  testWidgets('SettingsPage shows validation errors', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: SettingsPage()));
    await tester.pump();

    // Load settings
    controller.settings.value = testSettings;
    await tester.pump();

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
    when(mockDatabaseService.saveSettings(any)).thenAnswer((_) async {});
    when(
      mockNotificationService.onSettingsChanged(),
    ).thenAnswer((_) async => true);

    await tester.pumpWidget(const GetMaterialApp(home: SettingsPage()));
    await tester.pump();

    // Load settings
    controller.settings.value = testSettings;
    await tester.pump();

    // Change interval
    await tester.tap(find.text('1 ชั่วโมง'));
    await tester.pump();
    await tester.tap(find.text('30 นาที'));
    await tester.pump();

    // Save
    await tester.tap(find.text('บันทึก'));
    await tester.pump();

    // Verify save and notification update
    verify(mockDatabaseService.saveSettings(any)).called(1);
    verify(mockNotificationService.onSettingsChanged()).called(1);
  });
}
