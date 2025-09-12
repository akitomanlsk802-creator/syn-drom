import 'package:mockito/mockito.dart';
import 'package:office_syndrome_helper/services/contracts/database_service.dart';
import 'package:office_syndrome_helper/services/contracts/notification_service.dart';
import 'package:office_syndrome_helper/services/random_service.dart';

// The class name should end with .dart
class MockDatabaseService extends Mock implements IDatabaseService {}

class MockNotificationService extends Mock implements INotificationService {
  @override
  Future<bool> handleSnooze(String sessionId) async => noSuchMethod(
    Invocation.method(#handleSnooze, [sessionId]),
    returnValue: Future<bool>.value(false),
  );
}

class MockRandomService extends Mock implements RandomService {
  @override
  List<Map<String, dynamic>> getTwoExercisesFor(List<String> painPoints) =>
      noSuchMethod(
        Invocation.method(#getTwoExercisesFor, [painPoints]),
        returnValue: <Map<String, dynamic>>[],
      );
}
