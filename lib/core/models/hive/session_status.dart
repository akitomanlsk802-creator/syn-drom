import 'package:hive/hive.dart';

part 'session_status.g.dart';

@HiveType(typeId: 10)
enum SessionStatus {
  @HiveField(0)
  scheduled,
  @HiveField(1)
  started,
  @HiveField(2)
  completed,
  @HiveField(3)
  skipped,
  @HiveField(4)
  snoozed,
}
