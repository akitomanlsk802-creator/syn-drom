import 'package:flutter_test/flutter_test.dart';
import 'package:office_syndrome_helper/data/data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Static Data Tests', () {
    group('Schema & Counts', () {
      test('treatments count must be 19', () {
        expect(treatmentsData.length, equals(19));
      });

      test('pain points count is 11', () {
        expect(painPointsData.length, equals(11));
      });

      test('pain points ids are unique', () {
        final ids = painPointsData.map((e) => e['id'] as String).toList();
        expect(
          ids.toSet().length,
          equals(ids.length),
          reason: 'duplicated pain point id',
        );
      });
    });

    group('Data Structure', () {
      test('pain points have all required fields', () {
        for (final p in painPointsData) {
          expect(p['id'], isA<String>());
          expect(p['name'], isA<String>());
          expect(p['description'], isA<String>());
          expect(p['symptoms'], isA<List>());
        }
      });

      test('treatments have all required fields', () {
        for (final t in treatmentsData) {
          expect(t['id'], isA<String>());
          expect(t['name'], isA<String>());
          expect(t['steps'], isA<List<String>>());
          expect(t['durationSec'], isA<int>());
          expect(t['repeat'], isA<int>());
          expect(t['painPoints'], isA<List<String>>());
          if (t.containsKey('caution') && t['caution'] != null) {
            expect(t['caution'], isA<String>());
          }
        }
      });
    });

    group('References Integrity', () {
      test('treatments refer to valid pain points only', () {
        final validIds = painPointsData.map((p) => p['id'] as String).toSet();
        for (final t in treatmentsData) {
          for (final pid in t['painPoints'] as List) {
            expect(
              validIds.contains(pid),
              isTrue,
              reason: 'Treatment ${t['id']} refers to invalid pain point: $pid',
            );
          }
        }
      });

      test('core pain points have at least 2 treatments each', () {
        final core = [
          'neck',
          'shoulders',
          'upper_back',
          'lower_back',
          'wrist',
          'forearm',
        ];
        for (final pid in core) {
          final treatments = treatmentsData
              .where((t) => (t['painPoints'] as List).contains(pid))
              .toList();
          expect(
            treatments.length >= 2,
            isTrue,
            reason:
                'Core pain point $pid has only ${treatments.length} treatments',
          );
        }
      });
    });
  });
}
