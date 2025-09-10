import 'package:hive/hive.dart';
import 'session_status.dart';

part 'notification_session.g.dart';

@HiveType(typeId: 1)
class NotificationSession extends HiveObject {
  @HiveField(0)
  final int scheduledMinutes; // นาทีตั้งแต่ 00:00

  @HiveField(1)
  SessionStatus status;

  @HiveField(2)
  final DateTime date;

  NotificationSession({
    required this.scheduledMinutes,
    this.status = SessionStatus.scheduled,
    required this.date,
  });
}
