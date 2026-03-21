class Product {
  final int id;
  final String name;
  final double price;
  final double originalPrice;
  final String image;
  final int sales;
  final double rating;
  final String description;
  final int categoryId;
  final int stock;
  final List<String> colors;
  final List<String> sizes;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.sales,
    required this.rating,
    required this.description,
    required this.categoryId,
    required this.stock,
    this.colors = const [],
    this.sizes = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      sales: json['sales'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      stock: json['stock'] ?? 0,
      colors: json['colors'] != null ? List<String>.from(json['colors']) : [],
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'image': image,
      'sales': sales,
      'rating': rating,
      'description': description,
      'categoryId': categoryId,
      'stock': stock,
      'colors': colors,
      'sizes': sizes,
    };
  }
}
