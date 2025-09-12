import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:office_syndrome_helper/services/contracts/database_service.dart';
import 'package:office_syndrome_helper/services/contracts/notification_service.dart';
import 'package:office_syndrome_helper/services/random_service.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';
import 'package:office_syndrome_helper/utils/clock.dart';

class TodoController extends GetxController {
  static TodoController? _instance;
  static TodoController get I {
    _instance ??= TodoController._();
    return _instance!;
  }

  @visibleForTesting
  static void setInstance(TodoController instance) {
    _instance = instance;
  }

  final IDatabaseService _databaseService;
  final INotificationService _notificationService;
  final RandomService _randomService;
  final sessionId = ''.obs;
  final exercises = <Map<String, dynamic>>[].obs;
  final loading = false.obs;
  final error = ''.obs;
  final canSnooze = true.obs;

  TodoController._()
    : _databaseService = Get.find<IDatabaseService>(),
      _notificationService = Get.find<INotificationService>(),
      _randomService = Get.find<RandomService>();

  @visibleForTesting
  TodoController({
    required IDatabaseService databaseService,
    required INotificationService notificationService,
    required RandomService randomService,
    required String initialSessionId,
  }) : _databaseService = databaseService,
       _notificationService = notificationService,
       _randomService = randomService {
    sessionId.value = initialSessionId;
    _instance = this;
  }

  Future<void> loadExercises(List<String> painPoints) async {
    try {
      loading.value = true;
      error.value = '';
      exercises.value = _randomService.getTwoExercisesFor(painPoints);
    } catch (e) {
      error.value = 'เกิดข้อผิดพลาดในการโหลดท่าออกกำลังกาย';
    } finally {
      loading.value = false;
    }
  }

  Future<void> onDone() async {
    try {
      loading.value = true;
      error.value = '';

      final stats = await _databaseService.getTodayStats();
      final today = _getTodayYmd();

      await _databaseService.upsertDailyStats(
        DailyStats(
          dateLocalYmd: today,
          completed: (stats?.completed ?? 0) + 1,
          snoozed: stats?.snoozed ?? 0,
          skipped: stats?.skipped ?? 0,
        ),
      );

      Get.back(); // Return to HomePage
    } catch (e) {
      error.value = 'Failed to mark as done: $e';
    } finally {
      loading.value = false;
    }
  }

  Future<bool> onSnooze() async {
    try {
      loading.value = true;
      error.value = '';

      if (sessionId.value.isEmpty) return false;

      // Check if snoozing is allowed
      final stats = await _databaseService.getTodayStats();
      print('TodoController: getTodayStats result = ${stats?.snoozed}');
      final currentSnoozed = (stats?.snoozed ?? 0);
      print('TodoController: currentSnoozed = $currentSnoozed');
      if (currentSnoozed >= 3) {
        canSnooze.value = false;
        return false;
      }

      print('TodoController: sessionId.value = ${sessionId.value}');
      final success = await _notificationService.handleSnooze(sessionId.value);
      print('TodoController: handleSnooze result = $success');
      if (success) {
        final today = _getTodayYmd();

        await _databaseService.upsertDailyStats(
          DailyStats(
            dateLocalYmd: today,
            completed: stats?.completed ?? 0,
            snoozed: (stats?.snoozed ?? 0) + 1,
            skipped: stats?.skipped ?? 0,
          ),
        );

        try {
          Get.back(); // Return to HomePage
        } catch (e) {
          print('TodoController: Error in Get.back() = $e');
          // Ignore navigation error in tests
        }
      }
      return success;
    } catch (e) {
      print('TodoController: Error in onSnooze = $e');
      error.value = 'Failed to snooze: $e';
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> onSkip() async {
    try {
      loading.value = true;
      error.value = '';

      final stats = await _databaseService.getTodayStats();
      final today = _getTodayYmd();

      await _databaseService.upsertDailyStats(
        DailyStats(
          dateLocalYmd: today,
          completed: stats?.completed ?? 0,
          snoozed: stats?.snoozed ?? 0,
          skipped: (stats?.skipped ?? 0) + 1,
        ),
      );

      Get.back(); // Return to HomePage
    } catch (e) {
      error.value = 'Failed to skip: $e';
    } finally {
      loading.value = false;
    }
  }

  String _getTodayYmd() {
    final now = Clock.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
