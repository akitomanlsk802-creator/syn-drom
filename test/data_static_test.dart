import 'package:flutter_test/flutter_test.dart';
import 'package:office_syndrome_helper/data/treatments_data.dart';
import 'package:office_syndrome_helper/data/pain_points_data.dart';

void main() {

  test('treatments count must be 19', () {
    expect(treatmentsData.length, equals(19));
  });

  group('Pain Points Data Structure', () {
    test('each pain point has required fields', () {
      for (final point in painPointsData) {
        expect(point.containsKey('id'), true);
        expect(point.containsKey('name'), true);
        expect(point.containsKey('description'), true);
        expect(point.containsKey('symptoms'), true);
        
        expect(point['id'], isA<String>());
        expect(point['name'], isA<String>());
        expect(point['description'], isA<String>());
        expect(point['symptoms'], isA<List>());
      }
    });
  });

  group('Treatments Data Structure', () {
    test('each treatment has required fields', () {
      for (final treatment in treatmentsData) {
        expect(treatment.containsKey('id'), true);
        expect(treatment.containsKey('name'), true);
        expect(treatment.containsKey('steps'), true);
        expect(treatment.containsKey('durationSec'), true);
        expect(treatment.containsKey('repeat'), true);
        expect(treatment.containsKey('painPoints'), true);
        
        expect(treatment['id'], isA<String>());
        expect(treatment['name'], isA<String>());
        expect(treatment['steps'], isA<List>());
        expect(treatment['durationSec'], isA<int>());
        expect(treatment['repeat'], isA<int>());
        expect(treatment['painPoints'], isA<List>());
        expect((treatment['painPoints'] as List).isNotEmpty, true);
      }
    });

    test('treatments painPoints reference valid pain point ids', () {
      final validPainPointIds = painPointsData.map((p) => p['id'] as String).toSet();
      
      for (final treatment in treatmentsData) {
        for (final pointId in treatment['painPoints'] as List) {
          expect(validPainPointIds.contains(pointId), true,
            reason: 'Treatment ${treatment['id']} references invalid pain point: $pointId');
        }
      }
    });

    test('treatments have correct field types', () {
      for (final treatment in treatmentsData) {
        expect(treatment['id'], isA<String>());
        expect(treatment['name'], isA<String>());
        expect(treatment['steps'], isA<List<String>>());
        expect(treatment['durationSec'], isA<int>());
        expect(treatment['repeat'], isA<int>());
        expect(treatment['painPoints'], isA<List<String>>());
        expect(treatment['caution'], isA<String>());

        // Check no extra fields
        final keys = treatment.keys.toSet();
        expect(
          keys,
          equals({'id', 'name', 'steps', 'durationSec', 'repeat', 'painPoints', 'caution'}),
          reason: 'Treatment ${treatment['id']} has unexpected fields'
        );
      }
    });
  });

  group('Critical Pain Points Coverage', () {
    final criticalPoints = [
      'neck',
      'shoulders',
      'upper_back',
      'lower_back',
      'wrist',
      'forearm'
    ];

    for (final point in criticalPoints) {
      test('$point has at least 2 treatments', () {
        final treatments = treatmentsData.where((t) =>
          (t['painPoints'] as List).contains(point)
        ).toList();
        
        expect(treatments.length >= 2, true,
          reason: 'Pain point $point has ${treatments.length} treatments, needs at least 2');
      });
    }
  });
}
