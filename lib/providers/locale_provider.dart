import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('zh', 'CN');

  static const String _localeKey = 'locale';
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey) ?? 'zh';
      _locale = Locale(localeCode);
      _isInitialized = true;
    } catch (e) {
      _locale = const Locale('zh', 'CN');
      _isInitialized = true;
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // 忽略保存错误
    }
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'zh') {
      setLocale(const Locale('en', 'US'));
    } else {
      setLocale(const Locale('zh', 'CN'));
    }
  }

  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'zh':
        return '简体中文';
      case 'en':
        return 'English';
      default:
        return '简体中文';
    }
  }
}
