import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum AdSource { config, api }

class DebugSettings {
  static const _keyAdStartupEnabled = 'debug_ad_startup_enabled';
  static const _keyAdSource = 'debug_ad_source';
  static const _keyAdEnabled = 'debug_ad_enabled';
  static const _keyAdDelay = 'debug_ad_delay';
  static const _keyAdImageUrl = 'debug_ad_image_url';
  static const _keyAdTitle = 'debug_ad_title';
  static const _keyAdContent = 'debug_ad_content';

  static const _keyUpgradeEnabled = 'debug_upgrade_enabled';
  static const _keyUpgradeTitle = 'debug_upgrade_title';
  static const _keyUpgradeVersion = 'debug_upgrade_version';
  static const _keyUpgradeDescription = 'debug_upgrade_description';
  static const _keyUpgradeDownloadUrl = 'debug_upgrade_download_url';
  static const _keyUpgradeForceUpdate = 'debug_upgrade_force_update';

  static DebugSettings? _instance;
  static Completer<void>? _initCompleter;
  late SharedPreferences _prefs;

  DebugSettings._();

  static Future<DebugSettings> getInstance() async {
    if (_instance == null) {
      _initCompleter = Completer<void>();
      _instance = DebugSettings._();
      _instance!._prefs = await SharedPreferences.getInstance();
      _initCompleter!.complete();
    } else {
      await _initCompleter?.future;
    }
    return _instance!;
  }

  bool get adStartupEnabled => _prefs.getBool(_keyAdStartupEnabled) ?? false;
  AdSource get adSource {
    final v = _prefs.getString(_keyAdSource) ?? 'api';
    return v == 'config' ? AdSource.config : AdSource.api;
  }

  bool get adDebugEnabled => _prefs.getBool(_keyAdEnabled) ?? false;
  int get adDelaySeconds => _prefs.getInt(_keyAdDelay) ?? 2;
  String get adImageUrl =>
      _prefs.getString(_keyAdImageUrl) ??
      'https://picsum.photos/600/300?random=999';
  String get adTitle => _prefs.getString(_keyAdTitle) ?? '';
  String get adContent => _prefs.getString(_keyAdContent) ?? '';

  bool get upgradeEnabled => _prefs.getBool(_keyUpgradeEnabled) ?? false;
  String get upgradeTitle => _prefs.getString(_keyUpgradeTitle) ?? '发现新版本';
  String get upgradeVersion => _prefs.getString(_keyUpgradeVersion) ?? '1.0.0';
  String get upgradeDescription =>
      _prefs.getString(_keyUpgradeDescription) ??
      '1. 优化用户体验\n2. 修复已知问题\n3. 提升性能表现';
  String get upgradeDownloadUrl =>
      _prefs.getString(_keyUpgradeDownloadUrl) ?? '';
  bool get upgradeForceUpdate =>
      _prefs.getBool(_keyUpgradeForceUpdate) ?? false;

  Future<void> setAdStartupEnabled(bool value) =>
      _prefs.setBool(_keyAdStartupEnabled, value);

  Future<void> setAdSource(AdSource value) => _prefs.setString(
    _keyAdSource,
    value == AdSource.config ? 'config' : 'api',
  );

  Future<void> setAdDebugEnabled(bool value) =>
      _prefs.setBool(_keyAdEnabled, value);

  Future<void> setAdDelaySeconds(int value) =>
      _prefs.setInt(_keyAdDelay, value);

  Future<void> setAdImageUrl(String value) =>
      _prefs.setString(_keyAdImageUrl, value);

  Future<void> setAdTitle(String value) => _prefs.setString(_keyAdTitle, value);

  Future<void> setAdContent(String value) =>
      _prefs.setString(_keyAdContent, value);

  Future<void> setUpgradeEnabled(bool value) =>
      _prefs.setBool(_keyUpgradeEnabled, value);

  Future<void> setUpgradeTitle(String value) =>
      _prefs.setString(_keyUpgradeTitle, value);

  Future<void> setUpgradeVersion(String value) =>
      _prefs.setString(_keyUpgradeVersion, value);

  Future<void> setUpgradeDescription(String value) =>
      _prefs.setString(_keyUpgradeDescription, value);

  Future<void> setUpgradeDownloadUrl(String value) =>
      _prefs.setString(_keyUpgradeDownloadUrl, value);

  Future<void> setUpgradeForceUpdate(bool value) =>
      _prefs.setBool(_keyUpgradeForceUpdate, value);

  Future<void> resetAdConfig() async {
    await _prefs.remove(_keyAdDelay);
    await _prefs.remove(_keyAdImageUrl);
    await _prefs.remove(_keyAdTitle);
    await _prefs.remove(_keyAdContent);
  }
}
