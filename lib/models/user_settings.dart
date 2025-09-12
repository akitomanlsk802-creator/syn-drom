import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 0)
class UserSettings {
  @HiveField(0)
  final List<int> workingDays;

  @HiveField(1)
  final int workStartMinutes;

  @HiveField(2)
  final int workEndMinutes;

  @HiveField(3)
  final int intervalMinutes;

  @HiveField(4)
  final List<Map<String, dynamic>> breakPeriods;

  @HiveField(5)
  final List<String> selectedPainPoints;

  UserSettings({
    required this.workingDays,
    required this.workStartMinutes,
    required this.workEndMinutes,
    required this.intervalMinutes,
    List<Map<String, dynamic>>? breakPeriods,
    List<String>? selectedPainPoints,
  }) : breakPeriods = breakPeriods ?? [],
       selectedPainPoints = selectedPainPoints ?? [];

  // Validation methods
  bool get isValid =>
      _validateWorkingDays() &&
      _validateWorkHours() &&
      _validateIntervalMinutes() &&
      _validateBreakPeriods();

  bool _validateWorkingDays() {
    if (workingDays.isEmpty) return false;
    return workingDays.every((day) => day >= 1 && day <= 7);
  }

  bool _validateWorkHours() {
    return workStartMinutes >= 0 &&
        workStartMinutes < 1440 &&
        workEndMinutes > workStartMinutes &&
        workEndMinutes <= 1440;
  }

  bool _validateIntervalMinutes() {
    const validIntervals = {30, 45, 60, 90, 120};
    return validIntervals.contains(intervalMinutes);
  }

  bool _validateBreakPeriods() {
    if (breakPeriods.isEmpty) return true;

    // Sort breaks by start time
    final sorted = List<Map<String, dynamic>>.from(breakPeriods)
      ..sort((a, b) => (a['startMin'] as int).compareTo(b['startMin'] as int));

    // Check for overlaps
    for (var i = 0; i < sorted.length - 1; i++) {
      final current = sorted[i];
      final next = sorted[i + 1];
      if (current['endMin'] > next['startMin']) {
        return false;
      }
    }

    // Validate each period's bounds
    return breakPeriods.every((period) {
      final start = period['startMin'] as int;
      final end = period['endMin'] as int;
      return start >= 0 && end < 1440 && start < end;
    });
  }
}
