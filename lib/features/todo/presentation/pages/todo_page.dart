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
                            Text(
                              exercise['name'] as String,
                              style: Get.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exercise['description'] as String,
                              style: Get.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await controller.onDone();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('บันทึกการทำแล้ว'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('เสร็จแล้ว'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.colorScheme.primaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    final canSnooze = controller.canSnooze.value;
                    return ElevatedButton.icon(
                      onPressed: canSnooze
                          ? () async {
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
                            }
                          : null,
                      icon: const Icon(Icons.snooze),
                      label: Text(
                        canSnooze ? 'เลื่อน 15 นาที' : 'เลื่อนไม่ได้แล้ว',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Get.theme.colorScheme.secondaryContainer,
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await controller.onSkip();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ข้ามการทำครั้งนี้'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    icon: const Icon(Icons.skip_next),
                    label: const Text('ข้าม'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.colorScheme.errorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
