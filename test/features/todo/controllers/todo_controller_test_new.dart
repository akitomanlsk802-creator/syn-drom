import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:office_syndrome_helper/features/todo/controllers/todo_controller.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';
import '../../../mocks/services.dart';
import '../../../utils/test_helpers.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockNotificationService mockNotificationService;
  late MockRandomService mockRandomService;
  late TodoController todoController;

  setUp(() {
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
    Get.reset();
  });

  group('TodoController Tests', () {
    test('getTwoExercises returns non-duplicate exercises', () {
      final painPoints = ['neck', 'shoulder'];
      when(mockRandomService.getTwoExercisesFor(painPoints)).thenReturn([
        {'name': 'Exercise 1', 'description': 'Description 1'},
        {'name': 'Exercise 2', 'description': 'Description 2'},
      ]);

      todoController.loadExercises(painPoints);

      expect(todoController.exercises.length, 2);
      expect(todoController.exercises[0]['name'], 'Exercise 1');
      expect(todoController.exercises[1]['name'], 'Exercise 2');
      verify(mockRandomService.getTwoExercisesFor(painPoints)).called(1);
    });

    test('onDone increments completed count', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];
      when(mockDatabaseService.getTodayStats())
          .thenAnswer((_) async => createTestStats(dateLocalYmd: today));

      await todoController.onDone();

      final captured = verify(mockDatabaseService.upsertDailyStats(captureAny))
          .captured
          .single as DailyStats;
      verifyDailyStats(captured, dateLocalYmd: today, completed: 1);
    });

    test('onSnooze respects maxSnoozeCount', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Test snooze within limit
      when(mockDatabaseService.getTodayStats()).thenAnswer(
        (_) async => createTestStats(dateLocalYmd: today, snoozed: 2),
      );
      when(mockNotificationService.handleSnooze('test_session'))
          .thenAnswer((_) async => true);

      final canSnooze = await todoController.onSnooze();
      expect(canSnooze, true);
      verify(mockNotificationService.handleSnooze('test_session')).called(1);
      
      final captured = verify(mockDatabaseService.upsertDailyStats(captureAny))
          .captured
          .single as DailyStats;
      verifyDailyStats(captured, dateLocalYmd: today, snoozed: 3);

      // Test snooze at limit
      when(mockDatabaseService.getTodayStats()).thenAnswer(
        (_) async => createTestStats(dateLocalYmd: today, snoozed: 3),
      );

      final cannotSnooze = await todoController.onSnooze();
      expect(cannotSnooze, false);
      verifyNever(mockNotificationService.handleSnooze('test_session'));
    });

    test('onSkip increments skipped count', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];
      when(mockDatabaseService.getTodayStats())
          .thenAnswer((_) async => createTestStats(dateLocalYmd: today));

      await todoController.onSkip();

      final captured = verify(mockDatabaseService.upsertDailyStats(captureAny))
          .captured
          .single as DailyStats;
      verifyDailyStats(captured, dateLocalYmd: today, skipped: 1);
    });
  });
}
