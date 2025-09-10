import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive/user_settings.dart';
import '../models/hive/notification_session.dart';
import '../models/hive/session_status.dart';
import '../models/hive/daily_stats.dart';

class DatabaseService {
  static const _secureStorageKey = 'hive_encryption_key';
  static const _secureStorage = FlutterSecureStorage();

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Get or generate encryption key
    String? encryptionKey = await _secureStorage.read(key: _secureStorageKey);
    if (encryptionKey == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(key: _secureStorageKey, value: key.join(','));
      encryptionKey = key.join(',');
    }

    // Register adapters
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(NotificationSessionAdapter());
    Hive.registerAdapter(SessionStatusAdapter());
    Hive.registerAdapter(DailyStatsAdapter());

    // Open boxes with encryption
    final key = encryptionKey.split(',').map((e) => int.parse(e)).toList();
    await Future.wait([
      Hive.openBox<UserSettings>(
        'userSettings',
        encryptionCipher: HiveAesCipher(key),
      ),
      Hive.openBox<NotificationSession>(
        'notificationSessions',
        encryptionCipher: HiveAesCipher(key),
      ),
      Hive.openBox<DailyStats>(
        'dailyStats',
        encryptionCipher: HiveAesCipher(key),
      ),
    ]);
  }
}
