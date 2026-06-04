import 'dart:math';

import 'package:flutter/foundation.dart';
import '../data/services/mock_data_service.dart';
import '../data/services/user_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _userInfo;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  Map<String, dynamic>? get userInfo => _userInfo;
  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;

  bool get isLoggedIn {
    if (_userInfo == null) return false;
    final token = _userInfo!['token'] as String?;
    return token != null && token.isNotEmpty;
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await UserPreferences.getInstance();
      _userInfo = prefs.loadUser();

      final orders = await MockDataService.getOrders();
      _orders = orders;
    } catch (e) {
      debugPrint('ProfileProvider loadData error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadData();
  }

  Future<void> login(String phone, String password) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    _userInfo = {
      'id': 'user_$now',
      'name': '用户${phone.substring(phone.length - 4)}',
      'phone': phone,
      'avatar': '',
      'level': 1,
      'points': 0,
      'token': 'token_${now}_${_randomString(16)}',
    };
    final prefs = await UserPreferences.getInstance();
    await prefs.saveUser(_userInfo!);
    notifyListeners();
  }

  Future<void> register(String phone, String password) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    _userInfo = {
      'id': 'user_$now',
      'name': '用户${phone.substring(phone.length - 4)}',
      'phone': phone,
      'avatar': '',
      'level': 1,
      'points': 100,
      'token': 'token_${now}_${_randomString(16)}',
    };
    final prefs = await UserPreferences.getInstance();
    await prefs.saveUser(_userInfo!);
    notifyListeners();
  }

  Future<void> logout() async {
    _userInfo = null;
    final prefs = await UserPreferences.getInstance();
    await prefs.clearUser();
    notifyListeners();
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  int get pendingOrderCount {
    try {
      final pending = _orders.firstWhere((o) => o['status'] == 'pending');
      return pending['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  int get shippedOrderCount {
    try {
      final shipped = _orders.firstWhere((o) => o['status'] == 'shipped');
      return shipped['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  int get completedOrderCount {
    try {
      final completed = _orders.firstWhere((o) => o['status'] == 'completed');
      return completed['count'] as int;
    } catch (e) {
      return 0;
    }
  }
}
