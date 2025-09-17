class NotificationSession {
  final DateTime startTime;
  final DateTime endTime;
  bool isActive;

  NotificationSession({
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });
}
