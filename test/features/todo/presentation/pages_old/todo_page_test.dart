import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:office_syndrome_helper/features/todo/presentation/pages/todo_page.dart';
import 'package:office_syndrome_helper/features/todo/controllers/todo_controller.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';

import 'mock_random_service.dart';
import 'mock_database_service.dart';
import 'mock_notification_service.dart';

void main() {
  late MockRandomService randomService;
  late MockDatabaseService databaseService;
  late MockNotificationService notificationService;
  late TodoController controller;

  setUp(() {
    randomService = MockRandomService();
    databaseService = MockDatabaseService();
    notificationService = MockNotificationService();
    controller = TodoController(
      randomService: randomService,
      databaseService: databaseService,
      notificationService: notificationService,
      initialSessionId: '123',
    );
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('TodoPage', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      when(randomService.getTwoExercisesFor(['neck'])).thenReturn([]);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TodoPage(painPoints: ['neck'], sessionId: '123'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows exercises when loaded', (tester) async {
      final exercises = [
        {'name': 'Exercise 1', 'description': 'Description 1'},
        {'name': 'Exercise 2', 'description': 'Description 2'},
      ];

      when(randomService.getTwoExercisesFor(['neck'])).thenReturn(exercises);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TodoPage(painPoints: ['neck'], sessionId: '123'),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Exercise 1'), findsOneWidget);
      expect(find.text('Exercise 2'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);
      expect(find.text('Description 2'), findsOneWidget);
    });

    testWidgets('shows error message when loading fails', (tester) async {
      when(
        randomService.getTwoExercisesFor(['neck']),
      ).thenThrow(Exception('Error'));

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TodoPage(painPoints: ['neck'], sessionId: '123'),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('เกิดข้อผิดพลาดในการโหลดท่าออกกำลังกาย'),
        findsOneWidget,
      );
    });

    testWidgets('calls onDone when done button is pressed', (tester) async {
      when(
        randomService.getTwoExercisesFor(['neck']),
      ).thenAnswer((_) async => []);
      final expectedStats = DailyStats(
        dateLocalYmd: '2024-01-01',
        completed: 1,
        snoozed: 0,
        skipped: 0,
      );
      when(
        databaseService.getTodayStats(),
      ).thenAnswer((_) async => expectedStats);
      when(
        databaseService.upsertDailyStats(expectedStats),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TodoPage(painPoints: ['neck'], sessionId: '123'),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('เสร็จแล้ว'));
      await tester.pumpAndSettle();

      verify(databaseService.upsertDailyStats(expectedStats)).called(1);
    });

    testWidgets('calls onSnooze when snooze button is pressed', (tester) async {
      when(
        randomService.getTwoExercisesFor(['neck']),
      ).thenAnswer((_) async => []);
      when(
        notificationService.handleSnooze('123'),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TodoPage(painPoints: ['neck'], sessionId: '123'),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('เลื่อน 15 นาที'));
      await tester.pumpAndSettle();

      verify(notificationService.handleSnooze('123')).called(1);
    });

    testWidgets('navigates back when skip button is pressed', (tester) async {
      when(
        randomService.getTwoExercisesFor(['neck']),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: TodoPage(painPoints: ['neck'], sessionId: '123'),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('ข้าม'));
      await tester.pumpAndSettle();

      expect(find.byType(TodoPage), findsNothing);
    });
  });
}
