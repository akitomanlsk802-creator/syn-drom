import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../models/notification_session.dart';
import '../models/session_status.dart';
import '../models/daily_stats.dart';
import 'contracts/i_database_service.dart';

class DatabaseService implements IDatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get I {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  DatabaseService._();

  static const _encryptionKeyKey = 'hive_encryption_key';
  static const _userSettingsBox = 'user_settings.box';
  static const _notificationSessionBox = 'notification_session.box';
  static const _dailyStatsBox = 'daily_stats.box';

  late final Box<UserSettings> _settingsBox;
  late final Box<NotificationSession> _sessionBox;
  late final Box<DailyStats> _statsBox;

  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NotificationSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DailyStatsAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(SessionStatusAdapter());
    }

    final encryptionKey = await _getOrCreateEncryptionKey();

    await Hive.initFlutter();

    _settingsBox = await Hive.openBox<UserSettings>(
      _userSettingsBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    _sessionBox = await Hive.openBox<NotificationSession>(
      _notificationSessionBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    _statsBox = await Hive.openBox<DailyStats>(
      _dailyStatsBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<List<int>> _getOrCreateEncryptionKey() async {
    final existingKey = await secureStorage.read(key: _encryptionKeyKey);
    if (existingKey != null) {
      return existingKey.split(',').map((s) => int.parse(s)).toList();
    }

    final key = Hive.generateSecureKey();
    await secureStorage.write(key: _encryptionKeyKey, value: key.join(','));
    return key;
  }

  @override
  Future<UserSettings> loadOrCreateDefaults() async {
    final existing = await getSettings();
    if (existing != null) return existing;

    final defaults = UserSettings(
      workingDays: [1, 2, 3, 4, 5], // Mon-Fri
      workStartMinutes: 9 * 60, // 9:00
      workEndMinutes: 17 * 60, // 17:00
      intervalMinutes: 60,
    );

    await saveSettings(defaults);
    return defaults;
  }

  @override
  Future<UserSettings?> getSettings() async {
    return _settingsBox.get('settings');
  }

  Future<void> saveSettings(UserSettings settings) async {
    if (!settings.isValid) {
      throw Exception('Invalid settings');
    }
    await _settingsBox.put('settings', settings);
  }

  @override
  Future<void> putSession(NotificationSession session) async {
    await _sessionBox.put(session.id, session);
  }

  @override
  Future<List<NotificationSession>> listSessions({
    DateTime? from,
    DateTime? to,
  }) async {
    final sessions = _sessionBox.values.toList();
    return sessions.where((s) {
      if (from != null && s.scheduledAt.isBefore(from)) return false;
      if (to != null && s.scheduledAt.isAfter(to)) return false;
      return true;
    }).toList();
  }

  Future<DailyStats?> getDailyStats(String ymd) async {
    return _statsBox.get(ymd);
  }

  Future<void> upsertDailyStats(DailyStats stats) async {
    await _statsBox.put(stats.dateLocalYmd, stats);
  }

  @override
  Future<DailyStats?> getTodayStats() async {
    final today = DateTime.now();
    final ymd =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getDailyStats(ymd);
  }
}
