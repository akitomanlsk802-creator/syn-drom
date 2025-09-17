import 'dart:convert';

import '../utils/constants.dart';
import '../utils/validators.dart';

/// เก็บใน Hive (box: Boxes.settings, key: 'settings') เป็น Map<String,dynamic>
/// ไม่ต้องใช้ TypeAdapter/Generator
class UserSettings {
  final bool notificationsEnabled;
  final int workStartMinutes; // 0..1439
  final int workEndMinutes; // 1..1440 และ > workStart
  final List<int> workingDays; // 1=Mon .. 7=Sun
  final int intervalMinutes; // 30..120 (วันนี้กำหนดช่วงนี้)
  final List<Map<String, int>>
  breakPeriods; // [{"start":..,"end":..}, ...] ไม่ซ้อน
  final List<String> selectedPainPointIds; // เลือก 1–3 จุด
  final bool soundEnabled; // แจ้งเตือนมีเสียงไหม
  final bool vibrateEnabled; // สั่นไหม
  final int maxSnoozeCount; // เช่น 3

  const UserSettings({
    required this.notificationsEnabled,
    required this.workStartMinutes,
    required this.workEndMinutes,
    required this.workingDays,
    required this.intervalMinutes,
    required this.breakPeriods,
    required this.selectedPainPointIds,
    required this.soundEnabled,
    required this.vibrateEnabled,
    required this.maxSnoozeCount,
  });

  factory UserSettings.defaults() => UserSettings(
    notificationsEnabled: true,
    workStartMinutes: Consts.defaultWorkStartMinutes,
    workEndMinutes: Consts.defaultWorkEndMinutes,
    workingDays: Consts.defaultWorkingDays,
    intervalMinutes: Consts.defaultIntervalMinutes,
    breakPeriods: const [],
    selectedPainPointIds: const [],
    soundEnabled: true,
    vibrateEnabled: true,
    maxSnoozeCount: Consts.defaultMaxSnoozeCount,
  );

  UserSettings copyWith({
    bool? notificationsEnabled,
    int? workStartMinutes,
    int? workEndMinutes,
    List<int>? workingDays,
    int? intervalMinutes,
    List<Map<String, int>>? breakPeriods,
    List<String>? selectedPainPointIds,
    bool? soundEnabled,
    bool? vibrateEnabled,
    int? maxSnoozeCount,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      workStartMinutes: workStartMinutes ?? this.workStartMinutes,
      workEndMinutes: workEndMinutes ?? this.workEndMinutes,
      workingDays: workingDays ?? this.workingDays,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      breakPeriods: breakPeriods ?? this.breakPeriods,
      selectedPainPointIds: selectedPainPointIds ?? this.selectedPainPointIds,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'workStartMinutes': workStartMinutes,
      'workEndMinutes': workEndMinutes,
      'workingDays': workingDays,
      'intervalMinutes': intervalMinutes,
      'breakPeriods': breakPeriods, // already list of map<int,int>
      'selectedPainPointIds': selectedPainPointIds,
      'soundEnabled': soundEnabled,
      'vibrateEnabled': vibrateEnabled,
      'maxSnoozeCount': maxSnoozeCount,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    final breaks =
        (map['breakPeriods'] as List?)
            ?.map((e) => Map<String, int>.from((e as Map)))
            .toList() ??
        <Map<String, int>>[];

    BreakPeriodValidator.ensureValid(breaks);

    final ws =
        map['workStartMinutes'] as int? ?? Consts.defaultWorkStartMinutes;
    final we = map['workEndMinutes'] as int? ?? Consts.defaultWorkEndMinutes;
    if (ws < 0 || ws >= 1440 || we <= 0 || we > 1440 || ws >= we) {
      throw ArgumentError('Invalid work time range: start=$ws end=$we');
    }

    final interval =
        map['intervalMinutes'] as int? ?? Consts.defaultIntervalMinutes;
    if (interval < Consts.minInterval || interval > Consts.maxInterval) {
      throw ArgumentError('Invalid intervalMinutes: $interval');
    }

    final days = List<int>.from(
      map['workingDays'] ?? Consts.defaultWorkingDays,
    );
    for (final d in days) {
      if (d < 1 || d > 7) {
        throw ArgumentError('Invalid working day: $d');
      }
    }

    return UserSettings(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      workStartMinutes: ws,
      workEndMinutes: we,
      workingDays: days,
      intervalMinutes: interval,
      breakPeriods: breaks,
      selectedPainPointIds: List<String>.from(
        map['selectedPainPointIds'] ?? const <String>[],
      ),
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrateEnabled: map['vibrateEnabled'] as bool? ?? true,
      maxSnoozeCount:
          map['maxSnoozeCount'] as int? ?? Consts.defaultMaxSnoozeCount,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory UserSettings.fromJson(String src) =>
      UserSettings.fromMap(jsonDecode(src) as Map<String, dynamic>);
}
