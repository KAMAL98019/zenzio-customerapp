// lib/data/models/category_model.dart
class Category {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int? displayOrder;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.displayOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? json['category_name'] ?? '',
      description: json['description'],
      image: json['image'] ?? json['category_image'],
      displayOrder: json['display_order'] ?? json['displayOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'display_order': displayOrder,
    };
  }
}