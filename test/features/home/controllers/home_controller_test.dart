import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:office_syndrome_helper/features/home/controllers/home_controller.dart';
import 'package:office_syndrome_helper/services/contracts/index.dart';
import 'package:office_syndrome_helper/utils/clock.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';

class MockNotificationService extends Mock implements INotificationService {}

class MockDatabaseService extends Mock implements IDatabaseService {}

void main() {
  late HomeController controller;
  late MockNotificationService notif;
  late MockDatabaseService db;

  setUp(() {
    notif = MockNotificationService();
    db = MockDatabaseService();
    controller = HomeController(notif: notif, db: db);
  });

  group('Pain Points', () {
    test('should validate pain points count', () {
      expect(() => controller.setPainPoints([]), throwsA(isA<ArgumentError>()));
      expect(
        () => controller.setPainPoints(['1', '2', '3', '4']),
        throwsA(isA<ArgumentError>()),
      );

      controller.setPainPoints(['neck']);
      expect(controller.selectedPainPoints, ['neck']);

      controller.setPainPoints(['neck', 'back']);
      expect(controller.selectedPainPoints, ['neck', 'back']);
    });

    test('should validate pain point removal', () {
      controller.setPainPoints(['neck', 'back']);

      expect(
        () => controller.removePainPoint('back'),
        throwsA(isA<ArgumentError>()),
      );

      controller.setPainPoints(['neck', 'back', 'shoulder']);
      controller.removePainPoint('back');
      expect(controller.selectedPainPoints, ['neck', 'shoulder']);
    });
  });

  group('Daily Stats', () {
    test('calculates stats correctly', () async {
      const todayYmd = '2025-09-11';
      final stats = DailyStats(
        dateLocalYmd: todayYmd,
        completed: 5,
        snoozed: 2,
        skipped: 1,
      );

      when(() => db.getTodayStats()).thenAnswer((_) async => stats);

      // Initialize controller which loads stats
      await controller.onInit();

      expect(controller.notificationCount, equals(8)); // 5 + 2 + 1
      expect(controller.completedCount, equals(5));
      expect(controller.successRate, equals('63%')); // (5/8 * 100).round()
    });

    test('handles empty stats', () async {
      when(() => db.getTodayStats()).thenAnswer((_) async => null);

      await controller.onInit();

      expect(controller.notificationCount, equals(0));
      expect(controller.completedCount, equals(0));
      expect(controller.successRate, equals('0%'));
    });
  });

  group('Timer and Notifications', () {
    tearDown(() {
      Clock.reset();
    });

    test('should stop timer on close', () {
      fakeAsync((async) {
        final now = DateTime(2025, 9, 10, 10, 0);
        Clock.setNow(() => now);
        when(
          () => notif.getNextScheduledTime(),
        ).thenReturn(now.add(const Duration(minutes: 30)));
        when(() => db.getTodayStats()).thenAnswer(
          (_) async => DailyStats(dateLocalYmd: '2025-09-10', completed: 0),
        );

        controller.onInit();
        async.elapse(const Duration(seconds: 1));

        expect(controller.remaining.value.inMinutes, equals(30));

        controller.onClose();
        Clock.setNow(() => now.add(const Duration(minutes: 15)));
        async.elapse(const Duration(seconds: 1));

        // remaining value should not update after onClose
        expect(controller.remaining.value.inMinutes, equals(30));
      });
    });
    test('should update remaining time', () {
      fakeAsync((async) {
        final now = DateTime(2025, 9, 10, 10, 0);
        Clock.setNow(() => now);
        final nextTime = now.add(const Duration(minutes: 30));

        when(() => notif.getNextScheduledTime()).thenReturn(nextTime);
        when(() => db.getTodayStats()).thenAnswer(
          (_) async => DailyStats(dateLocalYmd: '2025-09-10', completed: 0),
        );

        controller.onInit();
        async.elapse(const Duration(seconds: 1)); // Let the timer tick once

        expect(controller.remaining.value.inMinutes, equals(30));

        Clock.setNow(() => now.add(const Duration(minutes: 15)));
        async.elapse(const Duration(seconds: 1));
        expect(controller.remaining.value.inMinutes, equals(15));

        Clock.setNow(() => now.add(const Duration(minutes: 30)));
        async.elapse(const Duration(seconds: 1));
        expect(controller.remaining.value.inSeconds, equals(0));

        Clock.reset();
      });
    });
    test('should call showNow on notification test', () async {
      when(() => notif.showNow()).thenAnswer((_) => Future.value());
      when(() => db.getTodayStats()).thenAnswer(
        (_) async => DailyStats(dateLocalYmd: '2025-09-10', completed: 0),
      );

      await controller.onPressTestNotification();
      verify(() => notif.showNow()).called(1);
    });
  });
}
