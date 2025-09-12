import 'package:flutter_test/flutter_test.dart';
import 'package:office_syndrome_helper/services/break_time_service.dart';

void main() {
  late BreakTimeService service;

  setUp(() {
    service = BreakTimeService();
  });

  test('add valid break period', () {
    service.add(startMin: 600, endMin: 660); // 10:00-11:00
    final breaks = service.list();

    expect(breaks.length, equals(1));
    expect(breaks[0]['startMin'], equals(600));
    expect(breaks[0]['endMin'], equals(660));
  });

  test('reject overlapping periods', () {
    service.add(startMin: 600, endMin: 660); // 10:00-11:00

    expect(
      () => service.add(startMin: 630, endMin: 690), // 10:30-11:30
      throwsArgumentError,
    );
  });

  test('reject invalid time range', () {
    expect(() => service.add(startMin: -30, endMin: 60), throwsArgumentError);

    expect(() => service.add(startMin: 60, endMin: 1500), throwsArgumentError);

    expect(() => service.add(startMin: 120, endMin: 60), throwsArgumentError);
  });

  test('remove break period', () {
    service.add(startMin: 600, endMin: 660);
    expect(service.list().length, equals(1));

    service.removeAt(0);
    expect(service.list().length, equals(0));
  });

  test('reject invalid index on remove', () {
    expect(() => service.removeAt(0), throwsRangeError);
  });

  test('multiple non-overlapping periods', () {
    service.add(startMin: 600, endMin: 660); // 10:00-11:00
    service.add(startMin: 720, endMin: 780); // 12:00-13:00
    service.add(startMin: 840, endMin: 900); // 14:00-15:00

    final breaks = service.list();
    expect(breaks.length, equals(3));
  });

  test('breaks are sorted by start time', () {
    service.add(startMin: 840, endMin: 900); // 14:00-15:00
    service.add(startMin: 600, endMin: 660); // 10:00-11:00
    service.add(startMin: 720, endMin: 780); // 12:00-13:00

    final breaks = service.list();
    expect(breaks[0]['startMin'], equals(600));
    expect(breaks[1]['startMin'], equals(720));
    expect(breaks[2]['startMin'], equals(840));
  });
}
