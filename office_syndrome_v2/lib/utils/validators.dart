/// BreakPeriod รูปแบบ:
/// [{"start": minutesFromMidnight, "end": minutesFromMidnight}, ...]
class BreakPeriodValidator {
  static void ensureValid(List<Map<String, int>> breaks) {
    // 1) ค่า start/end ต้องอยู่ใน [0, 1440) และ start < end
    for (final b in breaks) {
      final s = b['start'] ?? -1;
      final e = b['end'] ?? -1;
      if (s < 0 || e < 0 || s >= 1440 || e > 1440) {
        throw ArgumentError('BreakPeriod out of range (0..1440): $b');
      }
      if (s >= e) {
        throw ArgumentError('BreakPeriod start must be < end: $b');
      }
    }
    // 2) ต้องไม่ซ้อนกัน
    final sorted = [...breaks]
      ..sort((a, b) => (a['start']!).compareTo(b['start']!));
    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];
      if (curr['start']! < prev['end']!) {
        throw ArgumentError('BreakPeriods overlap: $prev vs $curr');
      }
    }
  }
}
