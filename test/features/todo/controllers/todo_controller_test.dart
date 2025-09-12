import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:office_syndrome_helper/features/todo/controllers/todo_controller.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';

import '../../../mocks/services.mocks.dart';

void main() {
  late MockIDatabaseService mockDatabaseService;
  late MockINotificationService mockNotificationService;
  late MockRandomService mockRandomService;
  late TodoController todoController;

  setUpAll(() {
    Get.testMode = true;
  });

  setUp(() async {
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

    // Wait for observables to be updated
    await Future.delayed(Duration.zero);
  });

  tearDown(() {
    Get.reset();
  });

  group('TodoController Tests', () {
    test('getTwoExercises returns non-duplicate exercises', () {
      final painPoints = ['neck', 'shoulder'];
      when(mockRandomService.getTwoExercisesFor(painPoints)).thenReturn([
        {'name': 'Exercise 1', 'description': 'Description 1'}
            as Map<String, dynamic>,
        {'name': 'Exercise 2', 'description': 'Description 2'}
            as Map<String, dynamic>,
      ]);

      todoController.loadExercises(painPoints);

      expect(todoController.exercises.length, 2);
      expect(todoController.exercises[0]['name'], 'Exercise 1');
      expect(todoController.exercises[1]['name'], 'Exercise 2');
      verify(mockRandomService.getTwoExercisesFor(painPoints)).called(1);
    });

    test('onDone increments completed count', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayStats = DailyStats(dateLocalYmd: today);

      when(
        mockDatabaseService.getTodayStats(),
      ).thenAnswer((_) async => todayStats);

      when(
        mockDatabaseService.upsertDailyStats(argThat(isA<DailyStats>())),
      ).thenAnswer((_) async {});

      await todoController.onDone();

      verify(
        mockDatabaseService.upsertDailyStats(
          argThat(
            predicate<DailyStats>(
              (stats) =>
                  stats.dateLocalYmd == today &&
                  stats.completed == 1 &&
                  stats.snoozed == 0 &&
                  stats.skipped == 0,
            ),
          ),
        ),
      ).called(1);
    });

    test('onSnooze respects maxSnoozeCount', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final snoozeStats = DailyStats(dateLocalYmd: today, snoozed: 2);

      // Test snooze within limit
      when(
        mockDatabaseService.getTodayStats(),
      ).thenAnswer((_) async => snoozeStats);

      when(
        mockDatabaseService.upsertDailyStats(argThat(isA<DailyStats>())),
      ).thenAnswer((_) async {});

      when(
        mockNotificationService.handleSnooze('test_session'),
      ).thenAnswer((_) async => true);

      // Wait for mock setup to complete
      await Future.delayed(Duration.zero);

      final canSnooze = await todoController.onSnooze();
      print('sessionId = ${todoController.sessionId.value}');
      print('canSnooze = $canSnooze');
      expect(canSnooze, true);
      verify(mockNotificationService.handleSnooze('test_session')).called(1);

      verify(
        mockDatabaseService.upsertDailyStats(
          argThat(
            predicate<DailyStats>(
              (stats) =>
                  stats.dateLocalYmd == today &&
                  stats.completed == 0 &&
                  stats.snoozed == 3 &&
                  stats.skipped == 0,
            ),
          ),
        ),
      ).called(1);

      // Test snooze at limit
      when(
        mockDatabaseService.getTodayStats(),
      ).thenAnswer((_) async => DailyStats(dateLocalYmd: today, snoozed: 3));

      final cannotSnooze = await todoController.onSnooze();
      expect(cannotSnooze, false);
      verifyNever(mockNotificationService.handleSnooze('test_session'));
    });

    test('onSkip increments skipped count', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayStats = DailyStats(dateLocalYmd: today);

      when(
        mockDatabaseService.getTodayStats(),
      ).thenAnswer((_) async => todayStats);

      when(
        mockDatabaseService.upsertDailyStats(argThat(isA<DailyStats>())),
      ).thenAnswer((_) async {});

      await todoController.onSkip();

      verify(
        mockDatabaseService.upsertDailyStats(
          argThat(
            predicate<DailyStats>(
              (stats) =>
                  stats.dateLocalYmd == today &&
                  stats.completed == 0 &&
                  stats.snoozed == 0 &&
                  stats.skipped == 1,
            ),
          ),
        ),
      ).called(1);
    });
  });
}
