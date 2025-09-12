import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:office_syndrome_helper/utils/duration_format.dart';
import '../../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Office Syndrome Helper')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPainPointsSection(),
            const SizedBox(height: 24),
            _buildCountdownTimer(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildTodayStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildPainPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Pain Points', style: Get.textTheme.titleMedium),
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
                  ),
                )
                .toList(),
          ),
        ),
      ],
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
          Text('Next Exercise In', style: Get.textTheme.titleMedium),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              formatDuration(controller.remaining.value),
              style: Get.textTheme.headlineMedium,
            ),
          ),
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
          label: 'Test\nNotification',
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
        width: 96,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Get.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s Progress', style: Get.textTheme.titleMedium),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'Notifications',
                  value: controller.notificationCount.toString(),
                ),
                _buildStatItem(
                  label: 'Completed',
                  value: controller.completedCount.toString(),
                ),
                _buildStatItem(
                  label: 'Success Rate',
                  value: controller.successRate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required String label, required String value}) {
    return Column(
      children: [
        Text(value, style: Get.textTheme.headlineSmall),
        Text(label, style: Get.textTheme.labelSmall),
      ],
    );
  }
}
