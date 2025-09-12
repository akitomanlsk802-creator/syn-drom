import 'package:flutter/foundation.dart';
import '../../../services/contracts/i_notification_service.dart';
import '../../../services/contracts/i_database_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/database_service.dart';
import '../../../utils/clock.dart';
import '../../../models/daily_stats.dart';

import 'package:get/get.dart';
import 'dart:async';

class HomeController {
  static HomeController? _instance;
  static HomeController get I {
    _instance ??= HomeController._();
    return _instance!;
  }

  @visibleForTesting
  static void setInstance(HomeController instance) {
    _instance = instance;
  }

  final INotificationService _notificationService;
  final IDatabaseService _databaseService;
  final selectedPainPoints = <String>[].obs;
  final remaining = const Duration().obs;
  final todayStats = Rx<DailyStats?>(null);
  Timer? _timer;

  HomeController._()
    : _notificationService = NotificationService.I,
      _databaseService = DatabaseService.I;

  @visibleForTesting
  HomeController({
    required INotificationService notif,
    required IDatabaseService db,
  }) : _notificationService = notif,
       _databaseService = db {
    _instance = this;
  }

  Future<void> onInit() async {
    _startTimer();
    await _loadTodayStats();
  }

  Future<void> _loadTodayStats() async {
    final stats = await _databaseService.getTodayStats();
    todayStats.value =
        stats ??
        DailyStats(
          dateLocalYmd: _getTodayYmd(),
          completed: 0,
          snoozed: 0,
          skipped: 0,
        );
  }

  String _getTodayYmd() {
    final now = Clock.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int get notificationCount =>
      (todayStats.value?.completed ?? 0) +
      (todayStats.value?.snoozed ?? 0) +
      (todayStats.value?.skipped ?? 0);

  int get completedCount => todayStats.value?.completed ?? 0;

  String get successRate {
    final total = notificationCount;
    if (total == 0) return '0%';
    final completed = completedCount;
    final rate = (completed / total * 100).round();
    return '$rate%';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = _notificationService.getNextScheduledTime();
      if (next == null) {
        remaining.value = Duration.zero;
        return;
      }

      final now = Clock.now();
      if (next.isBefore(now)) {
        remaining.value = Duration.zero;
        return;
      }

      remaining.value = next.difference(now);
    });
  }

  void setPainPoints(List<String> points) {
    if (points.isEmpty || points.length > 3) {
      throw ArgumentError('Must select 1-3 pain points');
    }
    selectedPainPoints.value = List.from(points);
  }

  void removePainPoint(String point) {
    if (selectedPainPoints.length <= 2) {
      throw ArgumentError('Must keep at least one pain point');
    }
    selectedPainPoints.remove(point);
  }

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _databaseService.loadOrCreateDefaults();
  }

  Future<void> onPressTestNotification() async {
    await _notificationService.showNow();
  }

  DateTime? getNextScheduledNotification() {
    return _notificationService.getNextScheduledTime();
  }

  void onClose() {
    _timer?.cancel();
    _timer = null;
  }
}
