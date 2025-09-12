import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:office_syndrome_helper/features/todo/controllers/todo_controller.dart';
import 'package:office_syndrome_helper/features/todo/presentation/pages/todo_page.dart';
import 'package:office_syndrome_helper/models/daily_stats.dart';
import '../../../mocks/services.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockNotificationService mockNotificationService;
  late MockRandomService mockRandomService;
  late TodoController todoController;
  final today = DateTime.now().toIso8601String().split('T')[0];

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockNotificationService = MockNotificationService();
    mockRandomService = MockRandomService();

    todoController = TodoController(
      databaseService: mockDatabaseService,
      notificationService: mockNotificationService,
      randomService: mockRandomService,
      initialSessionId: 'test_session',
    );

    Get.put(todoController);
  });

  tearDown(() {
    Get.reset();
  });
}
