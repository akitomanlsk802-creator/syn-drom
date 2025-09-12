import 'package:mockito/annotations.dart';
import 'package:office_syndrome_helper/services/contracts/database_service.dart';
import 'package:office_syndrome_helper/services/contracts/notification_service.dart';
import 'package:office_syndrome_helper/services/random_service.dart';

@GenerateMocks([IDatabaseService, INotificationService, RandomService])
void main() {}
