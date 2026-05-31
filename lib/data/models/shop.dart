class Shop {
  final int id;
  final String name;
  final String logo;
  final String cover;
  final String description;
  final int followerCount;
  final double rating;
  final int productCount;
  final bool isFollowed;

  Shop({
    required this.id,
    required this.name,
    required this.logo,
    required this.cover,
    required this.description,
    this.followerCount = 0,
    this.rating = 5.0,
    this.productCount = 0,
    this.isFollowed = false,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      cover: json['cover'],
      description: json['description'],
      followerCount: json['followerCount'] ?? 0,
      rating: (json['rating'] ?? 5.0).toDouble(),
      productCount: json['productCount'] ?? 0,
      isFollowed: json['isFollowed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'cover': cover,
    'description': description,
    'followerCount': followerCount,
    'rating': rating,
    'productCount': productCount,
    'isFollowed': isFollowed,
  };
}
