import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:office_syndrome_helper/features/todo/controllers/todo_controller.dart';

class TodoPage extends GetView<TodoController> {
  const TodoPage({
    super.key,
    required this.painPoints,
    required this.sessionId,
  });

  final List<String> painPoints;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    // Set loading state first to ensure it shows
    controller.loading.value = true;

    // Trigger loading after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.sessionId.value = sessionId;
      controller.loadExercises(painPoints);
    });

    return Scaffold(
      appBar: AppBar(title: Text('ถึงเวลาดูแล: ${painPoints.join(", ")}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Obx(() {
                if (controller.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.error.value,
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: Get.theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (controller.exercises.isEmpty) {
                  return Center(
                    child: Text(
                      'ไม่พบท่าออกกำลังกาย',
                      style: Get.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final exercise = controller.exercises[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    exercise['name'] as String,
                                    style: Get.textTheme.titleLarge,
                                  ),
                                ),
                                Icon(
                                  Icons.person_outline,
                                  color: Get.theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exercise['description'] as String,
                              style: Get.textTheme.bodyMedium,
                            ),
                            if (exercise.containsKey('target')) ...[
                              const SizedBox(height: 8),
                              Text(
                                'เป้าหมาย: ${exercise['target'] as String}',
                                style: Get.textTheme.bodySmall?.copyWith(
                                  color: Get.theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.loading.value
                          ? null
                          : () async {
                              await controller.onDone();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('บันทึกการทำแล้ว'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('เสร็จแล้ว'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          (controller.loading.value ||
                              !controller.canSnooze.value)
                          ? null
                          : () async {
                              final snoozed = await controller.onSnooze();
                              if (!context.mounted) return;
                              if (snoozed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('เลื่อนไปอีก 15 นาที'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.snooze),
                      label: Text(
                        controller.canSnooze.value
                            ? 'เลื่อน 15 นาที'
                            : 'เลื่อนไม่ได้แล้ว',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.loading.value
                          ? null
                          : () async {
                              await controller.onSkip();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ข้ามการทำครั้งนี้'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('ข้าม'),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
