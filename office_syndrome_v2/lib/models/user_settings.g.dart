// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
  notificationEnabled: json['notificationEnabled'] as bool? ?? false,
  notificationInterval: (json['notificationInterval'] as num?)?.toInt() ?? 30,
  workStartTime: json['workStartTime'] == null
      ? null
      : DateTime.parse(json['workStartTime'] as String),
  workEndTime: json['workEndTime'] == null
      ? null
      : DateTime.parse(json['workEndTime'] as String),
);

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'notificationEnabled': instance.notificationEnabled,
      'notificationInterval': instance.notificationInterval,
      'workStartTime': instance.workStartTime.toIso8601String(),
      'workEndTime': instance.workEndTime.toIso8601String(),
    };
