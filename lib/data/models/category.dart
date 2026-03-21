class Category {
  final int id;
  final String name;
  final String icon;
  final List<Category> children;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      children: json['children'] != null
          ? (json['children'] as List).map((e) => Category.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
