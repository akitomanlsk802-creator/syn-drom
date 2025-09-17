import 'dart:convert';

enum SessionStatus { scheduled, completed, snoozed, skipped }

class NotificationSession {
  final String id; // uuid
  final int scheduledEpochSec; // เวลาแจ้งเตือน (UTC epoch seconds)
  final String painPointId; // จุดที่สุ่มในรอบนี้
  final List<String> exerciseIds; // ท่าที่สุ่ม 1–2 ท่า
  final SessionStatus status;

  const NotificationSession({
    required this.id,
    required this.scheduledEpochSec,
    required this.painPointId,
    required this.exerciseIds,
    required this.status,
  });

  NotificationSession copyWith({
    String? id,
    int? scheduledEpochSec,
    String? painPointId,
    List<String>? exerciseIds,
    SessionStatus? status,
  }) {
    return NotificationSession(
      id: id ?? this.id,
      scheduledEpochSec: scheduledEpochSec ?? this.scheduledEpochSec,
      painPointId: painPointId ?? this.painPointId,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'scheduledEpochSec': scheduledEpochSec,
    'painPointId': painPointId,
    'exerciseIds': exerciseIds,
    'status': status.name,
  };

  factory NotificationSession.fromMap(Map<String, dynamic> map) {
    final stStr = map['status'] as String? ?? 'scheduled';
    final st = SessionStatus.values.firstWhere(
      (e) => e.name == stStr,
      orElse: () => SessionStatus.scheduled,
    );
    return NotificationSession(
      id: map['id'] as String,
      scheduledEpochSec: map['scheduledEpochSec'] as int,
      painPointId: map['painPointId'] as String,
      exerciseIds: List<String>.from(map['exerciseIds'] ?? const <String>[]),
      status: st,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory NotificationSession.fromJson(String src) =>
      NotificationSession.fromMap(jsonDecode(src) as Map<String, dynamic>);
}
