// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionStatusAdapter extends TypeAdapter<SessionStatus> {
  @override
  final int typeId = 10;

  @override
  SessionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SessionStatus.scheduled;
      case 1:
        return SessionStatus.started;
      case 2:
        return SessionStatus.completed;
      case 3:
        return SessionStatus.skipped;
      case 4:
        return SessionStatus.snoozed;
      default:
        return SessionStatus.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, SessionStatus obj) {
    switch (obj) {
      case SessionStatus.scheduled:
        writer.writeByte(0);
        break;
      case SessionStatus.started:
        writer.writeByte(1);
        break;
      case SessionStatus.completed:
        writer.writeByte(2);
        break;
      case SessionStatus.skipped:
        writer.writeByte(3);
        break;
      case SessionStatus.snoozed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
