import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'notification_service.dart';
import '../models/user_settings.dart';
import '../models/notification_session.dart';
import '../models/session_status.dart';
import '../utils/notification_utils.dart';
import '../utils/date_utils.dart';
import 'contracts/i_database_service.dart';
import 'contracts/i_notification_service.dart';

class NotificationController {
  static NotificationController? _instance;
  static NotificationController get I {
    _instance ??= NotificationController._();
    return _instance!;
  }

  // For testing - allows injecting mock services
  @visibleForTesting
  static void setInstance(NotificationController instance) {
    _instance = instance;
  }

  final IDatabaseService _dbService;
  final INotificationService _notifyService;
  bool _isInitialized = false;

  NotificationController._()
    : _dbService = DatabaseService.I,
      _notifyService = NotificationService.I;

  @visibleForTesting
  NotificationController({
    required IDatabaseService databaseService,
    required INotificationService notificationService,
  }) : _dbService = databaseService,
       _notifyService = notificationService {
    _instance = this; // Set the instance to this test instance
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _notifyService.initialize();
    _isInitialized = true;
  }

  Future<DateTime?> calculateNextNotificationTime(
    DateTime? last,
    UserSettings settings,
  ) async {
    final now = DateTime.now();
    DateTime candidate =
        last?.add(Duration(minutes: settings.intervalMinutes)) ?? now;

    while (true) {
      // Skip if not a working day
      if (!settings.workingDays.contains(candidate.weekday)) {
        candidate = DateTimeUtils.getMidnightLocal(candidate)
            .add(const Duration(days: 1))
            .add(Duration(minutes: settings.workStartMinutes));
        continue;
      }

      final minutesOfDay = DateTimeUtils.toMinutesOfDay(candidate);

      // Skip if outside working hours
      if (minutesOfDay < settings.workStartMinutes) {
        candidate = DateTimeUtils.fromMinutesOfDay(
          settings.workStartMinutes,
          candidate,
        );
        continue;
      }
      if (minutesOfDay > settings.workEndMinutes) {
        candidate = DateTimeUtils.getMidnightLocal(candidate)
            .add(const Duration(days: 1))
            .add(Duration(minutes: settings.workStartMinutes));
        continue;
      }

      // Skip if in break period
      bool isInBreak = false;
      for (final breakPeriod in settings.breakPeriods) {
        final startMin = breakPeriod['startMin'] as int;
        final endMin = breakPeriod['endMin'] as int;
        if (minutesOfDay >= startMin && minutesOfDay <= endMin) {
          candidate = DateTimeUtils.fromMinutesOfDay(endMin + 1, candidate);
          isInBreak = true;
          break;
        }
      }
      if (isInBreak) continue;

      // Valid time found
      return candidate;
    }
  }

  Future<void> onSettingsChanged() async {
    final settings = await _dbService.getSettings();
    if (settings == null) return;

    final lastSession = await _getLastSession();
    final next = await calculateNextNotificationTime(
      lastSession?.scheduledAt,
      settings,
    );

    if (next != null) {
      await _notifyService.cancelAll();
      final session = NotificationSession(
        id: NotificationUtils.generateSessionId(next),
        scheduledAt: next,
        status: SessionStatus.scheduled,
      );
      await _dbService.putSession(session);
      await _notifyService.scheduleAt(next, id: session.id);
    }
  }

  Future<void> rescheduleIfNeeded() async {
    final settings = await _dbService.getSettings();
    if (settings == null) return;

    final lastSession = await _getLastSession();
    if (lastSession == null) {
      await onSettingsChanged();
      return;
    }

    if (lastSession.status == SessionStatus.scheduled &&
        lastSession.scheduledAt.isAfter(DateTime.now())) {
      // Still valid
      return;
    }

    await onSettingsChanged();
  }

  Future<NotificationSession?> _getLastSession() async {
    final sessions = await _dbService.listSessions();
    if (sessions.isEmpty) return null;

    sessions.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return sessions.first;
  }

  Future<bool> handleSnooze(String sessionId) async {
    final session = (await _dbService.listSessions()).firstWhere(
      (s) => s.id == sessionId,
    );

    if (session.snoozeCount >= 2) {
      return false;
    }

    final newSession = NotificationSession(
      id: sessionId,
      scheduledAt: session.scheduledAt.add(const Duration(minutes: 5)),
      status: SessionStatus.snoozed,
      snoozeCount: session.snoozeCount + 1,
    );

    await _dbService.putSession(newSession);
    await _notifyService.scheduleAt(newSession.scheduledAt, id: newSession.id);

    return true;
  }
}
