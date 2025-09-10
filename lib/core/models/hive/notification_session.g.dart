// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSessionAdapter extends TypeAdapter<NotificationSession> {
  @override
  final int typeId = 1;

  @override
  NotificationSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSession(
      scheduledMinutes: fields[0] as int,
      status: fields[1] as SessionStatus,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSession obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.scheduledMinutes)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
