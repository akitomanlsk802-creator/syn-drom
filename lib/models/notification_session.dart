import 'package:hive/hive.dart';
import 'session_status.dart';

part 'notification_session.g.dart';

@HiveType(typeId: 1)
class NotificationSession {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime scheduledAt;

  @HiveField(2)
  final SessionStatus status;

  @HiveField(3)
  final int snoozeCount;

  NotificationSession({
    required this.id,
    required this.scheduledAt,
    required this.status,
    this.snoozeCount = 0,
  });
}
