// class Food {
//   final String id;
//   final String restId;
//   final String foodName;
//   final double price;
//   final bool veg;
//   final bool containAllergens;
//   final String? specifyAllergence;
//   final String? customisedOptions;
//   final String? description;
//   final String? image;
//   final String? cuisineId;
//   final String? categoryId;
//   final String? restaurant_uid;

//   Food({
//     required this.id,
//     required this.restId,
//     required this.restaurant_uid,
//     required this.foodName,
//     required this.price,
//     required this.veg,
//     required this.containAllergens,
//     this.specifyAllergence,
//     this.customisedOptions,
//     this.description,
//     this.image,
//     this.cuisineId,
//     this.categoryId,
//   });

//   factory Food.fromJson(Map<String, dynamic> json) {
//     return Food(
//       id: json['id'] ?? '',
//       restId: json['rest_id'] ?? '',
//       restaurantUid: json['restaurantUid'] ?? '',
//       foodName: json['dishname'] ?? '', // ✅ matches backend key
//       price: (json['price'] ?? 0).toDouble(),
//       veg: json['veg'] ?? false,
//       containAllergens: json['contain_allergens'] ?? false,
//       specifyAllergence: json['specify_allergence'] ?? '',
//       customisedOptions: json['customised_options']?.toString(),
//       description: json['description'] ?? '',
//       image: json['dishimage'] ?? '', // ✅ matches backend key
//       cuisineId: json['cuisineId'] ?? '',
//       categoryId: json['categoryId'] ?? '',
//     );
//   }


//   // String get name => null;

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'rest_id': restId,
//       'dishname': foodName,
//       'restaurantUid': restaurantUid,
//       'price': price,
//       'veg': veg,
//       'contain_allergens': containAllergens,
//       'specify_allergence': specifyAllergence,
//       'customised_options': customisedOptions,
//       'description': description,
//       'dishimage': image,
//       'cuisineId': cuisineId,
//       'categoryId': categoryId,
//     };
//   }
// }


class Food {
  final String id;
  final String restId;
  final String restaurantUid;   // <-- FIXED (camelCase)
  final String foodName;
  final double price;
  final bool veg;
  final bool containAllergens;
  final String? specifyAllergence;
  final String? customisedOptions;
  final String? description;
  final String? image;
  final String? cuisineId;
  final String? categoryId;

  Food({
    required this.id,
    required this.restId,
    required this.restaurantUid,    // <-- FIXED
    required this.foodName,
    required this.price,
    required this.veg,
    required this.containAllergens,
    this.specifyAllergence,
    this.customisedOptions,
    this.description,
    this.image,
    this.cuisineId,
    this.categoryId,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] ?? '',
      restId: json['rest_id'] ?? '',

      // ACCEPT BOTH KEYS (restaurant_uid or restaurantUid)
      restaurantUid: json['restaurant_uid'] ??
          json['restaurantUid'] ??
          "",

      foodName: json['dishname'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      veg: json['veg'] ?? false,
      containAllergens: json['contain_allergens'] ?? false,
      specifyAllergence: json['specify_allergence'] ?? '',
      customisedOptions: json['customised_options']?.toString(),
      description: json['description'] ?? '',
      image: json['dishimage'] ?? '',
      cuisineId: json['cuisineId'] ?? '',
      categoryId: json['categoryId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rest_id': restId,
      'restaurant_uid': restaurantUid,     // <-- FIXED
      'dishname': foodName,
      'price': price,
      'veg': veg,
      'contain_allergens': containAllergens,
      'specify_allergence': specifyAllergence,
      'customised_options': customisedOptions,
      'description': description,
      'dishimage': image,
      'cuisineId': cuisineId,
      'categoryId': categoryId,
    };
  }
}
