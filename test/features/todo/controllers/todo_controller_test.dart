import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:office_syndrome_helper/features/todo/controllers/todo_controller.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';
import 'package:office_syndrome_helper/services/contracts/database_service.dart';
import 'package:office_syndrome_helper/services/contracts/notification_service.dart';
import 'package:office_syndrome_helper/services/random_service.dart';

class MockDatabaseService extends Mock implements IDatabaseService {}

class MockNotificationService extends Mock implements INotificationService {}

class MockRandomService extends Mock implements RandomService {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockNotificationService mockNotificationService;
  late MockRandomService mockRandomService;
  late TodoController todoController;

  setUpAll(() {
    Get.testMode = true;
    registerFallbackValue(DailyStats(dateLocalYmd: '2025-09-12'));
    registerFallbackValue('test_session');
  });

  setUp(() async {
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

    // Wait for observables to be updated
    await Future.delayed(Duration.zero);
  });

  tearDown(() {
    Get.reset();
  });

  group('TodoController Tests', () {
    test('getTwoExercises returns non-duplicate exercises', () {
      final painPoints = ['neck', 'shoulder'];
      when(() => mockRandomService.getTwoExercisesFor(painPoints)).thenReturn([
        {'name': 'Exercise 1', 'description': 'Description 1'},
        {'name': 'Exercise 2', 'description': 'Description 2'},
      ]);

      todoController.loadExercises(painPoints);

      expect(todoController.exercises.length, 2);
      expect(todoController.exercises[0]['name'], 'Exercise 1');
      expect(todoController.exercises[1]['name'], 'Exercise 2');
      verify(() => mockRandomService.getTwoExercisesFor(painPoints)).called(1);
    });

    test('onDone increments completed count', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];
      when(
        () => mockDatabaseService.getTodayStats(),
      ).thenAnswer((_) async => DailyStats(dateLocalYmd: today));
      when(
        () => mockDatabaseService.upsertDailyStats(any()),
      ).thenAnswer((_) async {});

      await todoController.onDone();

      final captured =
          verify(
                () => mockDatabaseService.upsertDailyStats(captureAny()),
              ).captured.single
              as DailyStats;
      expect(captured.dateLocalYmd, today);
      expect(captured.completed, 1);
      expect(captured.snoozed, 0);
      expect(captured.skipped, 0);
    });

    test('onSnooze respects maxSnoozeCount', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Test snooze within limit
      when(
        () => mockDatabaseService.getTodayStats(),
      ).thenAnswer((_) async => DailyStats(dateLocalYmd: today, snoozed: 2));
      when(
        () => mockDatabaseService.upsertDailyStats(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockNotificationService.handleSnooze('test_session'),
      ).thenAnswer((_) async => true);

      // Wait for mock setup to complete
      await Future.delayed(Duration.zero);

      final canSnooze = await todoController.onSnooze();
      print('sessionId = ${todoController.sessionId.value}');
      print('canSnooze = $canSnooze');
      expect(canSnooze, true);
      verify(
        () => mockNotificationService.handleSnooze('test_session'),
      ).called(1);

      final captured =
          verify(
                () => mockDatabaseService.upsertDailyStats(captureAny()),
              ).captured.single
              as DailyStats;
      expect(captured.dateLocalYmd, today);
      expect(captured.completed, 0);
      expect(captured.snoozed, 3);
      expect(captured.skipped, 0);

      // Test snooze at limit
      when(
        () => mockDatabaseService.getTodayStats(),
      ).thenAnswer((_) async => DailyStats(dateLocalYmd: today, snoozed: 3));

      final cannotSnooze = await todoController.onSnooze();
      expect(cannotSnooze, false);
      verifyNever(() => mockNotificationService.handleSnooze('test_session'));
    });

    test('onSkip increments skipped count', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];
      when(
        () => mockDatabaseService.getTodayStats(),
      ).thenAnswer((_) async => DailyStats(dateLocalYmd: today));
      when(
        () => mockDatabaseService.upsertDailyStats(any()),
      ).thenAnswer((_) async {});

      await todoController.onSkip();

      final captured =
          verify(
                () => mockDatabaseService.upsertDailyStats(captureAny()),
              ).captured.single
              as DailyStats;
      expect(captured.dateLocalYmd, today);
      expect(captured.completed, 0);
      expect(captured.snoozed, 0);
      expect(captured.skipped, 1);
    });
  });
}
