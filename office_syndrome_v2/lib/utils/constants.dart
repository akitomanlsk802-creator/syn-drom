class Boxes {
  static const String settings = 'settings_box'; // 1 แถว (key: 'settings')
  static const String sessions = 'sessions_box'; // หลายแถว, ตาม sessionId
  static const String dailyStats =
      'daily_stats_box'; // 1 แถวต่อวันที่ (key: 'YYYY-MM-DD')
}

class Consts {
  // ค่าเริ่มต้นแนะนำ
  static const int defaultWorkStartMinutes = 9 * 60; // 09:00
  static const int defaultWorkEndMinutes = 17 * 60; // 17:00
  static const List<int> defaultWorkingDays = [
    1,
    2,
    3,
    4,
    5,
  ]; // จันทร์=1 ... อาทิตย์=7
  static const int defaultIntervalMinutes = 60;
  static const int defaultMaxSnoozeCount = 3;

  // ขอบเขต
  static const int minInterval = 30;
  static const int maxInterval = 120;
}
