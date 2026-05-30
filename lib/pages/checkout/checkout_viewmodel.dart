import 'package:flutter/material.dart';
import '../../data/models/address.dart';

class CheckoutViewModel extends ChangeNotifier {
  int _selectedPaymentIndex = 0;
  bool _isSubmitting = false;
  Address? _selectedAddress;

  int get selectedPaymentIndex => _selectedPaymentIndex;
  bool get isSubmitting => _isSubmitting;
  Address? get selectedAddress => _selectedAddress;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': '微信支付', 'icon': Icons.chat},
    {'name': '支付宝', 'icon': Icons.payment},
    {'name': '银行卡', 'icon': Icons.credit_card},
  ];

  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;

  void setSelectedAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setSelectedPaymentIndex(int index) {
    _selectedPaymentIndex = index;
    notifyListeners();
  }

  void setIsSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
