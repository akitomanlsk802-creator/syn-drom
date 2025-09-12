import 'package:workmanager/workmanager.dart';
import 'notification_controller.dart';

class BackgroundScheduler {
  static const _taskName = 'com.officesyndromehelper.notificationWatchdog';
  static bool _isRegistered = false;

  static Future<void> ensureRegistered() async {
    if (_isRegistered) return;

    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 60),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    _isRegistered = true;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == BackgroundScheduler._taskName) {
        final controller = NotificationController.I;
        await controller.initialize();
        await controller.rescheduleIfNeeded();
      }
      return true;
    } catch (e) {
      return false;
    }
  });
}
