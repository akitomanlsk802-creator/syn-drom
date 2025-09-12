abstract class INotificationService {
  Future<void> showNow();
  Future<void> initialize();
  Future<void> cancelAll();
  Future<void> scheduleAt(DateTime time, {required String id});
  DateTime? getNextScheduledTime();

  /// Called when settings are changed to reconfigure notifications
  Future<void> onSettingsChanged();
}
