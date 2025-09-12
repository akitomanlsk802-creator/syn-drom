class NotificationUtils {
  static String generateSessionId(DateTime scheduledAt) {
    return 'session_${scheduledAt.millisecondsSinceEpoch}';
  }

  static DateTime roundToNextInterval(DateTime dt, int intervalMinutes) {
    final totalMinutes = dt.hour * 60 + dt.minute;
    final nextInterval =
        ((totalMinutes + intervalMinutes - 1) ~/ intervalMinutes) *
        intervalMinutes;

    return DateTime(
      dt.year,
      dt.month,
      dt.day,
      nextInterval ~/ 60,
      nextInterval % 60,
    );
  }
}
