import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  static const _keyActivity = 'notification_activity';
  static const _keyMessage = 'notification_message';
  static const _keyUpdate = 'notification_update';

  static NotificationPreferences? _instance;
  late SharedPreferences _prefs;

  NotificationPreferences._();

  static Future<NotificationPreferences> getInstance() async {
    if (_instance == null) {
      _instance = NotificationPreferences._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  bool get activityEnabled => _prefs.getBool(_keyActivity) ?? false;
  bool get messageEnabled => _prefs.getBool(_keyMessage) ?? true;
  bool get updateEnabled => _prefs.getBool(_keyUpdate) ?? true;

  Future<void> setActivityEnabled(bool value) =>
      _prefs.setBool(_keyActivity, value);

  Future<void> setMessageEnabled(bool value) =>
      _prefs.setBool(_keyMessage, value);

  Future<void> setUpdateEnabled(bool value) =>
      _prefs.setBool(_keyUpdate, value);
}
