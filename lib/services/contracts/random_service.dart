abstract class IRandomService {
  /// Returns two random exercises based on the given pain points
  List<Map<String, dynamic>> getTwoExercisesFor(List<String> painPoints);
}
