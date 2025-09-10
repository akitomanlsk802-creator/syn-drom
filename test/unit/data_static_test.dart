// @dart=3.0
import 'package:flutter_test/flutter_test.dart';
import 'package:office_syndrome_helper/data/treatments_data.dart';

void main() {
  group('Static Data Tests', () {
    test('treatments count = 19 & schema valid', () {
      const SPEC_TREATMENT_COUNT = 19;
      expect(treatmentsData.length, SPEC_TREATMENT_COUNT);
      final ids = <String>{};
      for (final t in treatmentsData) {
        expect(t['id'], isA<String>());
        expect(ids.add(t['id']), true, reason: 'duplicated id: ${t['id']}');
        expect(t['name'], isA<String>());
        expect(t['steps'], isA<List<String>>());
        expect(t['durationSec'], isA<int>());
        expect(t['repeat'], isA<int>());
        expect(t['painPoints'], isA<List<String>>());
      }
    });

    test('each core pain point has >= 2 treatments', () {
      const core = [
        'neck',
        'shoulders',
        'upper_back',
        'lower_back',
        'wrist',
        'forearm'
      ];
      for (final pid in core) {
        final matches = treatmentsData.where(
          (t) => (t['painPoints'] as List).cast<String>().contains(pid),
        );
        expect(matches.length >= 2, true,
            reason: 'core $pid has < 2 treatments');
      }
    });
  });
}
