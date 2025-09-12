import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 0)
class UserSettings extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  int workStartMinutes; // นาทีตั้งแต่ 00:00

  @HiveField(2)
  int workEndMinutes; // นาทีตั้งแต่ 00:00

  @HiveField(3)
  List<Map<String, dynamic>> breakPeriods; // ไม่ใช้ Hive Adapter

  UserSettings({
    this.name,
    this.workStartMinutes = 540, // 09:00
    this.workEndMinutes = 1020, // 17:00
    List<Map<String, dynamic>>? breakPeriods,
  }) : breakPeriods = breakPeriods ?? [];
}
