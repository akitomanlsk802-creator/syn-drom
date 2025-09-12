// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import '../../../../mocks/services.mocks.dart';
import 'package:office_syndrome_helper/features/todo/controllers/todo_controller.dart';
import 'package:office_syndrome_helper/features/todo/presentation/pages/todo_page.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';
import 'package:office_syndrome_helper/utils/clock.dart';

DailyStats makeDailyStats({
  required String date,
  required int completed,
  required int snoozed,
  required int skipped,
}) => DailyStats(
  dateLocalYmd: date,
  completed: completed,
  snoozed: snoozed,
  skipped: skipped,
);

void main() {
  late MockIDatabaseService mockDatabaseService;
  late MockINotificationService mockNotificationService;
  late MockRandomService mockRandomService;
  late TodoController todoController;

  final todayDateTime = DateTime(2024, 3, 24);
  const today = '2024-03-24';
  final todayStats = DailyStats(dateLocalYmd: today);

  setUp(() {
    Clock.setNow(() => todayDateTime);
    mockDatabaseService = MockIDatabaseService();
    mockNotificationService = MockINotificationService();
    mockRandomService = MockRandomService();

    todoController = TodoController(
      databaseService: mockDatabaseService,
      notificationService: mockNotificationService,
      randomService: mockRandomService,
      initialSessionId: 'test_session',
    );

    Get.put(todoController);

    // Default mock for getTodayStats
    when(
      mockDatabaseService.getTodayStats(),
    ).thenAnswer((_) async => todayStats);
  });

  tearDown(() {
    Clock.reset();
    Get.reset();
  });

  testWidgets('TodoPage shows loading then exercises', (
    WidgetTester tester,
  ) async {
    final painPoints = ['neck', 'shoulder'];
    final exercises = <Map<String, dynamic>>[
      {'name': 'Exercise 1', 'description': 'Description 1'},
      {'name': 'Exercise 2', 'description': 'Description 2'},
    ];

    // Set up exercise loading
    when(
      mockRandomService.getTwoExercisesFor(painPoints),
    ).thenReturn(exercises);

    // Build widget and wait for first frame
    await tester.pumpWidget(
      GetMaterialApp(
        home: TodoPage(painPoints: painPoints, sessionId: 'test_session'),
      ),
    );

    // Loading indicator should be shown in first frame after initState
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let todo controller finish loading
    await tester.pumpAndSettle();

    // Now should show exercises
    expect(find.text('Exercise 1'), findsOneWidget);
    expect(find.text('Exercise 2'), findsOneWidget);
  });

  testWidgets('TodoPage handles done action', (WidgetTester tester) async {
    final painPoints = ['neck'];
    when(mockRandomService.getTwoExercisesFor(painPoints)).thenReturn([
      {'name': 'Exercise 1', 'description': 'Description 1'},
    ]);

    await tester.pumpWidget(
      GetMaterialApp(
        home: TodoPage(painPoints: painPoints, sessionId: 'test_session'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('เสร็จแล้ว'));
    await tester.pump();

    final expectedStats = makeDailyStats(
      date: today,
      completed: 1,
      snoozed: 0,
      skipped: 0,
    );
    verify(
      mockDatabaseService.upsertDailyStats(
        argThat(
          predicate<DailyStats>(
            (stats) =>
                stats.dateLocalYmd == expectedStats.dateLocalYmd &&
                stats.completed == expectedStats.completed &&
                stats.snoozed == expectedStats.snoozed &&
                stats.skipped == expectedStats.skipped,
          ),
        ),
      ),
    ).called(1);
  });

  testWidgets('TodoPage handles snooze action', (WidgetTester tester) async {
    final painPoints = ['neck'];
    when(mockRandomService.getTwoExercisesFor(painPoints)).thenReturn([
      {'name': 'Exercise 1', 'description': 'Description 1'},
    ]);
    when(
      mockNotificationService.handleSnooze('test_session'),
    ).thenAnswer((_) async => true);

    await tester.pumpWidget(
      GetMaterialApp(
        home: TodoPage(painPoints: painPoints, sessionId: 'test_session'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('เลื่อน 15 นาที'));
    await tester.pump();

    verify(mockNotificationService.handleSnooze('test_session')).called(1);
    final expectedStats = makeDailyStats(
      date: today,
      completed: 0,
      snoozed: 1,
      skipped: 0,
    );
    verify(
      mockDatabaseService.upsertDailyStats(
        argThat(
          predicate<DailyStats>(
            (stats) =>
                stats.dateLocalYmd == expectedStats.dateLocalYmd &&
                stats.completed == expectedStats.completed &&
                stats.snoozed == expectedStats.snoozed &&
                stats.skipped == expectedStats.skipped,
          ),
        ),
      ),
    ).called(1);
  });

  testWidgets('TodoPage handles skip action', (WidgetTester tester) async {
    final painPoints = ['neck'];
    when(mockRandomService.getTwoExercisesFor(painPoints)).thenReturn([
      {'name': 'Exercise 1', 'description': 'Description 1'},
    ]);

    await tester.pumpWidget(
      GetMaterialApp(
        home: TodoPage(painPoints: painPoints, sessionId: 'test_session'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ข้าม'));
    await tester.pump();

    final expectedStats = makeDailyStats(
      date: today,
      completed: 0,
      snoozed: 0,
      skipped: 1,
    );
    verify(
      mockDatabaseService.upsertDailyStats(
        argThat(
          predicate<DailyStats>(
            (stats) =>
                stats.dateLocalYmd == expectedStats.dateLocalYmd &&
                stats.completed == expectedStats.completed &&
                stats.snoozed == expectedStats.snoozed &&
                stats.skipped == expectedStats.skipped,
          ),
        ),
      ),
    ).called(1);
  });
}
