import 'product.dart';

class CartItem {
  final int id;
  final Product product;
  int quantity;
  bool isSelected;
  String? selectedColor;
  String? selectedSize;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.isSelected = true,
    this.selectedColor,
    this.selectedSize,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'isSelected': isSelected,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      isSelected: json['isSelected'] ?? true,
      selectedColor: json['selectedColor'],
      selectedSize: json['selectedSize'],
    );
  }
}
