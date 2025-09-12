import 'package:flutter/foundation.dart';

class Clock {
  static DateTime Function() _now = () => DateTime.now();

  static DateTime now() => _now();

  @visibleForTesting
  static void setNow(DateTime Function() fn) {
    _now = fn;
  }

  @visibleForTesting
  static void reset() {
    _now = () => DateTime.now();
  }
}
