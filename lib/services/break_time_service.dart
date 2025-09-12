class BreakTimeService {
  final List<Map<String, dynamic>> _breaks = [];

  List<Map<String, dynamic>> list() {
    return List.from(_breaks);
  }

  void add({required int startMin, required int endMin}) {
    _validateTimeRange(startMin, endMin);
    _validateNoOverlap(startMin, endMin);

    _breaks.add({'startMin': startMin, 'endMin': endMin});

    // Sort breaks by start time
    _breaks.sort((a, b) => a['startMin'].compareTo(b['startMin']));
  }

  void removeAt(int index) {
    if (index < 0 || index >= _breaks.length) {
      throw RangeError('Invalid break period index');
    }
    _breaks.removeAt(index);
  }

  void _validateTimeRange(int startMin, int endMin) {
    if (startMin < 0 || startMin >= 1440) {
      throw ArgumentError('Start time must be between 0 and 1439 minutes');
    }
    if (endMin <= startMin || endMin > 1440) {
      throw ArgumentError(
        'End time must be greater than start time and less than or equal to 1440 minutes',
      );
    }
  }

  void _validateNoOverlap(int startMin, int endMin) {
    for (final period in _breaks) {
      final existingStart = period['startMin'] as int;
      final existingEnd = period['endMin'] as int;

      if ((startMin >= existingStart && startMin < existingEnd) ||
          (endMin > existingStart && endMin <= existingEnd) ||
          (startMin <= existingStart && endMin >= existingEnd)) {
        throw ArgumentError('Break periods cannot overlap');
      }
    }
  }
}
