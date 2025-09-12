import 'package:fluttevoid main() {
  late MockDatabaseService mockDatabaseService;
  late MockNotificationService mockNotificationService;
  late MockRandomService mockRandomService;
  late TodoController todoController;
  final today = DateTime.now().toIso8601String().split('T')[0];

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockNotificationService = MockNotificationService();
    mockRandomService = MockRandomService();';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:office_syndrome_helper/features/todo/controllers/todo_controller.dart';
import 'package:office_syndrome_helper/features/todo/presentation/pages/todo_page.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';
import 'package:office_syndrome_helper/utils/clock.dart';
import '../../../../mocks/services.dart';

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
  late MockDatabaseService mockDatabaseService;
  late MockNotificationService mockNotificationService;
  late MockRandomService mockRandomService;
  late TodoController todoController;

  final todayDateTime = DateTime(2024, 3, 24);
  const today = '2024-03-24';
  final todayStats = DailyStats(dateLocalYmd: today);

  setUp(() {
    Clock.setNow(() => todayDateTime);
    mockDatabaseService = MockDatabaseService();
    mockNotificationService = MockNotificationService();
    mockRandomService = MockRandomService();

    todoController = TodoController(
      databaseService: mockDatabaseService,
      notificationService: mockNotificationService,
      randomService: mockRandomService,
      initialSessionId: 'test_session',
    );

    Get.put(todoController);
  });

  tearDown(() {
    Clock.reset();
    Get.reset();
  });

  testWidgets('TodoPage shows loading initially', (WidgetTester tester) async {
    final painPoints = ['neck', 'shoulder'];

    when(mockRandomService.getTwoExercisesFor(painPoints)).thenAnswer(
      (_) => [
        {'name': 'Exercise 1', 'description': 'Description 1'},
        {'name': 'Exercise 2', 'description': 'Description 2'},
      ],
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: TodoPage(painPoints: painPoints, sessionId: 'test_session'),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(); // Wait for exercises to load
    expect(find.text('Exercise 1'), findsOneWidget);
    expect(find.text('Exercise 2'), findsOneWidget);
  });

  testWidgets('TodoPage handles done action', (WidgetTester tester) async {
    final painPoints = ['neck'];
    when(mockRandomService.getTwoExercisesFor(painPoints)).thenAnswer(
      (_) => [
        {'name': 'Exercise 1', 'description': 'Description 1'},
      ],
    );
    when(
      mockDatabaseService.getTodayStats(),
    ).thenAnswer((_) async => todayStats);

    await tester.pumpWidget(
      GetMaterialApp(
        home: TodoPage(painPoints: painPoints, sessionId: 'test_session'),
      ),
    );
    await tester.pump();

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
    when(mockRandomService.getTwoExercisesFor(painPoints)).thenAnswer(
      (_) => [
        {'name': 'Exercise 1', 'description': 'Description 1'},
      ],
    );
    when(
      mockNotificationService.handleSnooze('test_session'),
    ).thenAnswer((_) async => true);
    when(
      mockDatabaseService.getTodayStats(),
    ).thenAnswer((_) async => todayStats);

    await tester.pumpWidget(
      GetMaterialApp(
        home: TodoPage(painPoints: painPoints, sessionId: 'test_session'),
      ),
    );
    await tester.pump();

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
    when(mockRandomService.getTwoExercisesFor(painPoints)).thenAnswer(
      (_) => [
        {'name': 'Exercise 1', 'description': 'Description 1'},
      ],
    );
    when(
      mockDatabaseService.getTodayStats(),
    ).thenAnswer((_) async => todayStats);

    await tester.pumpWidget(
      GetMaterialApp(
        home: TodoPage(painPoints: painPoints, sessionId: 'test_session'),
      ),
    );
    await tester.pump();

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
