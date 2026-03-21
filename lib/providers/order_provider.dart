import 'package:flutter/material.dart';
import '../data/models/order.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  List<Order> getPendingOrders() =>
      _orders.where((o) => o.status == 'pending').toList();
  List<Order> getPaidOrders() =>
      _orders.where((o) => o.status == 'paid').toList();
  List<Order> getShippedOrders() =>
      _orders.where((o) => o.status == 'shipped').toList();
  List<Order> getCompletedOrders() =>
      _orders.where((o) => o.status == 'completed').toList();

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _orders = List.generate(8, (index) {
      return Order(
        id: index + 1,
        orderNo: 'HL2024${(100000 + index).toString()}',
        items: _generateOrderItems(),
        totalPrice: 299.0 + index * 100,
        status: _getStatus(index),
        createTime: DateTime.now().subtract(Duration(days: index)),
        address: {
          'name': '张三',
          'phone': '138****8888',
          'province': '广东省',
          'city': '深圳市',
          'district': '南山区',
          'detail': '科技园南路88号',
        },
      );
    });

    _isLoading = false;
    notifyListeners();
  }

  List<CartItem> _generateOrderItems() {
    final names = ['iPhone 15 Pro', 'AirPods Pro', 'Apple Watch', 'MacBook'];
    return List.generate((DateTime.now().millisecond % 3) + 1, (i) {
      return CartItem(
        id: DateTime.now().millisecondsSinceEpoch + i,
        product: Product(
          id: i + 1,
          name: names[i % names.length],
          price: 99.0 + i * 50,
          originalPrice: 199.0 + i * 80,
          image: 'https://picsum.photos/300/300?random=${i + 30}',
          sales: 100 + i * 20,
          rating: 4.5,
          description: '优质商品',
          categoryId: 1,
          stock: 100,
        ),
        quantity: i + 1,
        isSelected: true,
      );
    });
  }

  String _getStatus(int index) {
    switch (index % 4) {
      case 0:
        return 'pending';
      case 1:
        return 'shipped';
      case 2:
        return 'completed';
      default:
        return 'paid';
    }
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrderStatus(int orderId, String status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = Order(
        id: _orders[index].id,
        orderNo: _orders[index].orderNo,
        items: _orders[index].items,
        totalPrice: _orders[index].totalPrice,
        status: status,
        createTime: _orders[index].createTime,
        address: _orders[index].address,
      );
      notifyListeners();
    }
  }

  void removeOrder(int orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }
}
