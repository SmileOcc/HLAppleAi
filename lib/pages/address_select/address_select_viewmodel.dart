import 'package:flutter/material.dart';
import '../../data/models/address.dart';

class AddressSelectViewModel extends ChangeNotifier {
  Address? _selectedAddress;
  List<Address> _addresses = [];

  Address? get selectedAddress => _selectedAddress;
  List<Address> get addresses => _addresses;

  void init(List<Address> addresses, Address? selectedAddress) {
    _addresses = addresses;
    _selectedAddress = selectedAddress;
    notifyListeners();
  }

  void setSelectedAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void addAddress(Address address) {
    _addresses.add(address);
    notifyListeners();
  }

  void updateAddress(Address address) {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      _addresses[index] = address;
      notifyListeners();
    }
  }

  void deleteAddress(int id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddress?.id == id) {
      _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
    }
    notifyListeners();
  }

  void setDefaultAddress(int id) {
    _addresses = _addresses.map((a) {
      return a.copyWith(isDefault: a.id == id);
    }).toList();
    if (_selectedAddress != null && _selectedAddress!.id == id) {
      _selectedAddress = _addresses.firstWhere((a) => a.id == id);
    }
    notifyListeners();
  }
}
