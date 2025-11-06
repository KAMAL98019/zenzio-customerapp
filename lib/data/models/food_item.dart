class FoodItem {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final bool? veg;
  final bool? containAllergens;
  final String? specifyAllergence;
  final String? imageUrl;
  final String? category;
  final String? cuisine;

  FoodItem({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.veg,
    this.containAllergens,
    this.specifyAllergence,
    this.imageUrl,
    this.category,
    this.cuisine,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? '',
      name: json['dishname'] ?? 'Unknown Dish',
      description: json['description'],
      price: (json['price'] != null)
          ? double.tryParse(json['price'].toString())
          : null,
      veg: json['veg'],
      containAllergens: json['contain_allergens'],
      specifyAllergence: json['specify_allergence'],
      imageUrl: json['dishimage'],
      category: json['category']?['name'],
      cuisine: json['cuisine']?['name'],
    );
  }

  get dishname => null;
}
