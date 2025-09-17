import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';

class UserSettingsService {
  final SharedPreferences sharedPreferences;
  static const String _settingsKey = 'user_settings';

  UserSettingsService({required this.sharedPreferences});

  Future<void> saveSettings(UserSettings settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await sharedPreferences.setString(_settingsKey, jsonString);
  }

  Future<UserSettings> loadSettings() async {
    final jsonString = sharedPreferences.getString(_settingsKey);
    if (jsonString == null) {
      return UserSettings(); // Return default settings
    }

    try {
      final json = jsonDecode(jsonString);
      return UserSettings.fromJson(json);
    } catch (e) {
      print('Error loading settings: $e');
      return UserSettings(); // Return default settings on error
    }
  }
}
