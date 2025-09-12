
abstract class NotificationService {
  Future<void> showNow({
    required String title,
    required String body,
    String? payload,
  });

  DateTime? getNextScheduledTime();
}
