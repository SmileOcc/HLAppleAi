import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _keyUser = 'cached_user';

  static UserPreferences? _instance;
  late SharedPreferences _prefs;

  UserPreferences._();

  static Future<UserPreferences> getInstance() async {
    if (_instance == null) {
      _instance = UserPreferences._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Map<String, dynamic>? loadUser() {
    final json = _prefs.getString(_keyUser);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_keyUser, jsonEncode(user));
  }

  Future<void> clearUser() async {
    await _prefs.remove(_keyUser);
  }
}
