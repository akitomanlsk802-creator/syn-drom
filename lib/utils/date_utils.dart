class DateTimeUtils {
  static DateTime getMidnightLocal(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  static int toMinutesOfDay(DateTime dt) {
    return dt.hour * 60 + dt.minute;
  }

  static DateTime fromMinutesOfDay(int minutes, [DateTime? baseDate]) {
    final date = baseDate ?? DateTime.now();
    return DateTime(
      date.year,
      date.month,
      date.day,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  static String toYmd(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static DateTime? fromYmd(String ymd) {
    try {
      final parts = ymd.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return null;
    }
  }
}
