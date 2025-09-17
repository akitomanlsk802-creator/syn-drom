import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

@JsonSerializable()
class UserSettings {
  final bool notificationEnabled;
  final int notificationInterval;
  final DateTime workStartTime;
  final DateTime workEndTime;

  UserSettings({
    this.notificationEnabled = false,
    this.notificationInterval = 30,
    DateTime? workStartTime,
    DateTime? workEndTime,
  }) : workStartTime = workStartTime ?? DateTime(2025, 1, 1, 9, 0),
       workEndTime = workEndTime ?? DateTime(2025, 1, 1, 17, 0);

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);
}
