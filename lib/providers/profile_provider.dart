import 'package:flutter/material.dart';
import '../data/services/mock_data_service.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _userInfo;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  Map<String, dynamic>? get userInfo => _userInfo;
  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userInfo != null;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        MockDataService.getCurrentUser(),
        MockDataService.getOrders(),
      ]);

      _userInfo = results[0] as Map<String, dynamic>;
      _orders = results[1] as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('ProfileProvider loadData error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadData();
  }

  void logout() {
    _userInfo = null;
    notifyListeners();
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
