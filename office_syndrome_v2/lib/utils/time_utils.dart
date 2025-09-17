import 'package:flutter/material.dart';

int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

TimeOfDay toTimeOfDay(int minutes) {
  final h = (minutes ~/ 60) % 24;
  final m = minutes % 60;
  return TimeOfDay(hour: h, minute: m);
}

/// แปลง DateTime -> key ของสถิติรายวัน เช่น "2025-09-17"
String ymdKey(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
