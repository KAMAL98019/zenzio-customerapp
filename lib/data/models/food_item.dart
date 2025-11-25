// class FoodItem {
//   final String id;
//   final String name;
//   final String? description;
//   final double? price;
//   final bool? veg;
//   final bool? containAllergens;
//   final String? specifyAllergence;
//   final String? imageUrl;
//   final String? category;
//   final String? cuisine;

//   FoodItem({
//     required this.id,
//     required this.name,
//     this.description,
//     this.price,
//     this.veg,
//     this.containAllergens,
//     this.specifyAllergence,
//     this.imageUrl,
//     this.category,
//     this.cuisine,
//   });

//   factory FoodItem.fromJson(Map<String, dynamic> json) {
//     return FoodItem(
//       id: json['id'] ?? '',
//       name: json['dishname'] ?? 'Unknown Dish',
//       description: json['description'],
//       price: (json['price'] != null)
//           ? double.tryParse(json['price'].toString())
//           : null,
//       veg: json['veg'],
//       containAllergens: json['contain_allergens'],
//       specifyAllergence: json['specify_allergence'],
//       imageUrl: json['dishimage'],
//       category: json['category']?['name'],
//       cuisine: json['cuisine']?['name'],
//     );
//   }

//   get dishname => null;
// }

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
  final String? restaurantUid;  

  FoodItem({
    required this.id,
    required this.name,
    this.description,
    this.restaurantUid,
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
      id: json['id'].toString(),
      name: json['menu_name'] ?? 'Unknown Dish',

      restaurantUid: json['restaurant_uid'] ??
                     json['restaurantUid'] ??
                     json['rest_uid'] ??
                     json['restaurantId'] ??
                     "",

      description: json['description'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      veg: (json['food_type']?.toString().toLowerCase() == 'veg'),
      containAllergens: json['contain_allergence'],
      specifyAllergence: json['specify_allergence'],

      imageUrl: (json['images'] != null && (json['images'] as List).isNotEmpty)
          ? (json['images'] as List).first.toString()
          : null,

      category: json['category'],
      cuisine: null, // API doesn't provide currently
    );
  }
}



// class FoodItem {
//   final int id;
//   final String name;
//   final String? description;
//   final double price;
//   final bool veg;
//   final bool containAllergens;
//   final String? specifyAllergence;
//   final String? imageUrl;
//   final String? category;
//   final double rating;
//   final List<AddOn> customizedOption;

//   FoodItem({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.veg,
//     required this.containAllergens,
//     required this.specifyAllergence,
//     required this.imageUrl,
//     required this.category,
//     required this.rating,
//     required this.customizedOption,
//   });

//   factory FoodItem.fromJson(Map<String, dynamic> json) {
//     return FoodItem(
//       id: json['id'],
//       name: json['menu_name'] ?? "",
//       description: json['description'],
//       price: (json['price'] ?? 0).toDouble(),
//       veg: (json['food_type']?.toString().toLowerCase() == "veg"),
//       containAllergens: json['contain_allergence'] ?? false,
//       specifyAllergence: json['specify_allergence'],
//       imageUrl: (json['images'] != null && (json['images'] as List).isNotEmpty)
//           ? json['images'][0]
//           : null,
//       category: json['category'],
//       rating: (json['rating'] ?? 0).toDouble(),
//       customizedOption: (json['customized_option'] as List?)
//               ?.map((e) => AddOn.fromJson(e))
//               .toList() ??
//           [],
//     );
//   }
// }

// class AddOn {
//   final String name;
//   final double price;

//   AddOn({required this.name, required this.price});

//   factory AddOn.fromJson(Map<String, dynamic> json) {
//     return AddOn(
//       name: json['name'] ?? "",
//       price: (json['price'] ?? 0).toDouble(),
//     );
//   }
// }
