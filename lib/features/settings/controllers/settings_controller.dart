// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:office_syndrome_helper/models/user_settings.dart';
import 'package:office_syndrome_helper/services/contracts/i_database_service.dart';
import 'package:office_syndrome_helper/services/contracts/i_notification_service.dart';

class SettingsController extends GetxController {
  final IDatabaseService _databaseService;
  final INotificationService _notificationService;

  final settings = Rx<UserSettings?>(null);
  final isSaving = false.obs;
  final formKey = GlobalKey<FormState>();

  SettingsController({
    required IDatabaseService databaseService,
    required INotificationService notificationService,
  }) : _databaseService = databaseService,
       _notificationService = notificationService;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    settings.value = await _databaseService.getSettings();
    update();
  }

  // Validation methods
  bool isValidInterval(int value) =>
      const {30, 45, 60, 90, 120}.contains(value);

  bool isValidWorkHours(int start, int end) =>
      start >= 0 && end <= 24 * 60 && start < end;

  bool hasOverlap(List<(int, int)> periods) {
    final sorted = [...periods]..sort((a, b) => a.$1.compareTo(b.$1));
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i - 1].$2 > sorted[i].$1) return true;
    }
    return false;
  }

  bool isValidPainPoints(List<String> painPoints) =>
      painPoints.isNotEmpty && painPoints.length <= 3;

  Future<bool> saveSettings(UserSettings newSettings) async {
    try {
      isSaving.value = true;

      // Validate
      if (!isValidInterval(newSettings.intervalMinutes)) return false;
      if (!isValidWorkHours(
        newSettings.workStartMinutes,
        newSettings.workEndMinutes,
      )) {
        return false;
      }
      if (!isValidPainPoints(newSettings.selectedPainPoints)) return false;

      // Save
      await _databaseService.saveSettings(newSettings);
      settings.value = newSettings;

      // Trigger notification reconfiguration
      await _notificationService.onSettingsChanged();

      return true;
    } finally {
      isSaving.value = false;
    }
  }
}
