import '../models/cart_item.dart';

class Order {
  final int id;
  final String orderNo;
  final List<CartItem> items;
  final double totalPrice;
  final String status;
  final DateTime createTime;
  final Map<String, dynamic> address;
  final String? remark;

  Order({
    required this.id,
    required this.orderNo,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createTime,
    required this.address,
    this.remark,
  });

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusText {
    switch (status) {
      case 'pending':
        return '待付款';
      case 'paid':
        return '待发货';
      case 'shipped':
        return '待收货';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return '未知';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'items': items.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createTime': createTime.toIso8601String(),
      'address': address,
      'remark': remark,
    };
  }
}
