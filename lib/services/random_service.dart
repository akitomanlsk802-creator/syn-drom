import 'dart:math';
import '../data/treatments_data.dart';
import 'contracts/random_service.dart';

class RandomService implements IRandomService {
  final _random = Random();

  @override
  List<Map<String, dynamic>> getTwoExercisesFor(List<String> painPoints) {
    if (painPoints.isEmpty) return [];

    // Filter treatments that match any of the selected pain points
    final matchingTreatments = treatmentsData.where((treatment) {
      final treatmentPoints = (treatment['painPoints'] as List).cast<String>();
      return painPoints.any((point) => treatmentPoints.contains(point));
    }).toList();

    if (matchingTreatments.isEmpty) return [];

    // Shuffle and take first 2 treatments
    matchingTreatments.shuffle(_random);
    return matchingTreatments.take(2).toList();
  }
}
