// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:office_syndrome_helper/models/user_settings.dart';
import 'package:office_syndrome_helper/features/settings/controllers/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ ตั้งค่า')),
      body: Obx(() {
        final settings = controller.settings.value;
        final isSaving = controller.isSaving.value;

        if (settings == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Notification toggle
              SwitchListTile(
                title: const Text('🔔 การแจ้งเตือน'),
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  settings.notificationsEnabled = value;
                  controller.update();
                },
              ),

              // Interval selector
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'ระยะห่างการแจ้งเตือน',
                ),
                initialValue: settings.intervalMinutes,
                items: const [
                  DropdownMenuItem(value: 30, child: Text('30 นาที')),
                  DropdownMenuItem(value: 45, child: Text('45 นาที')),
                  DropdownMenuItem(value: 60, child: Text('1 ชั่วโมง')),
                  DropdownMenuItem(value: 90, child: Text('1 ชั่วโมง 30 นาที')),
                  DropdownMenuItem(value: 120, child: Text('2 ชั่วโมง')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settings.intervalMinutes = value;
                    controller.update();
                  }
                },
                validator: (value) =>
                    value == null || !controller.isValidInterval(value)
                    ? 'โปรดเลือกระยะห่างที่ถูกต้อง'
                    : null,
              ),

              // Work hours
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'เวลาเริ่มงาน',
                      ),
                      initialValue:
                          '${(settings.workStartMinutes ~/ 60).toString().padLeft(
                            2,
                            '0',
                          )}:${(settings.workStartMinutes % 60).toString().padLeft(
                            2,
                            '0',
                          )}',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'โปรดระบุเวลาเริ่มงาน';
                        }
                        final parts = value.split(':');
                        if (parts.length != 2) return 'รูปแบบเวลาไม่ถูกต้อง';

                        try {
                          final hours = int.parse(parts[0]);
                          final minutes = int.parse(parts[1]);
                          final totalMinutes = hours * 60 + minutes;

                          if (!controller.isValidWorkHours(
                            totalMinutes,
                            settings.workEndMinutes,
                          )) {
                            return 'เวลาเริ่มต้องน้อยกว่าเวลาสิ้นสุด';
                          }

                          settings.workStartMinutes = totalMinutes;
                          return null;
                        } catch (e) {
                          return 'รูปแบบเวลาไม่ถูกต้อง';
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'เวลาเลิกงาน',
                      ),
                      initialValue:
                          '${(settings.workEndMinutes ~/ 60).toString().padLeft(
                            2,
                            '0',
                          )}:${(settings.workEndMinutes % 60).toString().padLeft(
                            2,
                            '0',
                          )}',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'โปรดระบุเวลาเลิกงาน';
                        }
                        final parts = value.split(':');
                        if (parts.length != 2) return 'รูปแบบเวลาไม่ถูกต้อง';

                        try {
                          final hours = int.parse(parts[0]);
                          final minutes = int.parse(parts[1]);
                          final totalMinutes = hours * 60 + minutes;

                          if (!controller.isValidWorkHours(
                            settings.workStartMinutes,
                            totalMinutes,
                          )) {
                            return 'เวลาสิ้นสุดต้องมากกว่าเวลาเริ่ม';
                          }

                          settings.workEndMinutes = totalMinutes;
                          return null;
                        } catch (e) {
                          return 'รูปแบบเวลาไม่ถูกต้อง';
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Working days
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('วันทำงาน'),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (int i = 1; i <= 7; i++)
                    FilterChip(
                      label: Text(_getDayName(i)),
                      selected: settings.workingDays.contains(i),
                      onSelected: (selected) {
                        if (selected) {
                          settings.workingDays.add(i);
                        } else {
                          settings.workingDays.remove(i);
                        }
                        controller.update();
                      },
                    ),
                ],
              ),

              // Sound & Vibration
              SwitchListTile(
                title: const Text('🔊 เสียง'),
                value: settings.soundEnabled,
                onChanged: (value) {
                  settings.soundEnabled = value;
                  controller.update();
                },
              ),
              SwitchListTile(
                title: const Text('📳 สั่น'),
                value: settings.vibrationEnabled,
                onChanged: (value) {
                  settings.vibrationEnabled = value;
                  controller.update();
                },
              ),

              // Max snooze count
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'จำนวนครั้งที่เลื่อนได้สูงสุด',
                ),
                initialValue: settings.maxSnoozeCount.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'โปรดระบุจำนวน';
                  final count = int.tryParse(value);
                  if (count == null || count < 0) {
                    return 'ต้องเป็นจำนวนเต็มไม่ติดลบ';
                  }
                  settings.maxSnoozeCount = count;
                  return null;
                },
              ),

              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (controller.formKey.currentState?.validate() ==
                              true) {
                            final success = await controller.saveSettings(
                              settings,
                            );
                            if (success) {
                              Get.back();
                            } else {
                              Get.snackbar(
                                'ผิดพลาด',
                                'ไม่สามารถบันทึกการตั้งค่าได้',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          }
                        },
                  child: Text(isSaving ? 'กำลังบันทึก...' : 'บันทึก'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'จ';
      case 2:
        return 'อ';
      case 3:
        return 'พ';
      case 4:
        return 'พฤ';
      case 5:
        return 'ศ';
      case 6:
        return 'ส';
      case 7:
        return 'อา';
      default:
        return '';
    }
  }
}
