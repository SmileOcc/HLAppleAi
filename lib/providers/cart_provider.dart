import 'package:flutter/material.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items
      .where((item) => item.isSelected)
      .fold(0.0, (sum, item) => sum + item.totalPrice);

  int get selectedCount => _items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.quantity);

  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.isSelected);

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _items = List.generate(8, (index) {
      return CartItem(
        id: index + 1,
        product: Product(
          id: index + 1,
          name: _getProductName(index),
          price: 99.0 + (index * 20),
          originalPrice: 199.0 + (index * 30),
          image: 'https://picsum.photos/300/300?random=${index + 20}',
          sales: 50 + index * 20,
          rating: 4.5,
          description: '优质商品',
          categoryId: index + 1,
          stock: 100,
        ),
        quantity: index % 3 + 1,
        isSelected: true,
      );
    });

    _isLoading = false;
    notifyListeners();
  }

  String _getProductName(int index) {
    final names = [
      'iPhone 15 Pro Max 256GB',
      'AirPods Pro 第二代',
      'Apple Watch S9',
      'MacBook Pro M2',
      'iPad Pro 12.9英寸',
      'MagSafe磁吸充电器',
      '数据线套装',
      '保护壳',
    ];
    return names[index % names.length];
  }

  void toggleSelect(int itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();
    }
  }

  void toggleAllSelect() {
    final allSelected = isAllSelected;
    for (var item in _items) {
      item.isSelected = !allSelected;
    }
    notifyListeners();
  }

  void updateQuantity(int itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void removeItem(int itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void addToCart(
    Product product, {
    String? selectedColor,
    String? selectedSize,
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor == selectedColor &&
          item.selectedSize == selectedSize,
    );
    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch,
          product: product,
          quantity: quantity,
          isSelected: true,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
        ),
      );
    }
    notifyListeners();
  }

  void updateCartItem(
    int itemId, {
    String? selectedColor,
    String? selectedSize,
    int? quantity,
  }) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (selectedColor != null) _items[index].selectedColor = selectedColor;
      if (selectedSize != null) _items[index].selectedSize = selectedSize;
      if (quantity != null && quantity > 0) _items[index].quantity = quantity;
      notifyListeners();
    }
  }
}
