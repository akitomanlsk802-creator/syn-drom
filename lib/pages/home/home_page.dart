import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:office_syndrome_helper/features/home/controllers/home_controller.dart';
import 'package:office_syndrome_helper/utils/duration_format.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Office Syndrome Helper')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPainPointsSection(),
            const SizedBox(height: 16),
            _buildCountdownTimer(),
            const SizedBox(height: 16),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPainPointsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Pain Points',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.selectedPainPoints
                  .map(
                    (point) => Chip(
                      label: Text(point),
                      deleteIcon: const Icon(Icons.cancel, size: 18),
                      onDeleted: () => controller.removePainPoint(point),
                      backgroundColor: Get.theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('Next Break', style: Get.textTheme.titleMedium),
          const SizedBox(height: 8),
          Obx(() {
            final d = controller.remaining.value;
            return Text(
              formatDuration(d),
              style: const TextStyle(
                fontSize: 32,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.notifications_active,
          label: 'Test Notify',
          onPressed: () => controller.onPressTestNotification(),
        ),
        _buildActionButton(
          icon: Icons.bar_chart,
          label: 'Statistics',
          onPressed: () => Get.toNamed('/statistics'),
        ),
        _buildActionButton(
          icon: Icons.settings,
          label: 'Settings',
          onPressed: () => Get.toNamed('/settings'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(label, style: Get.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
