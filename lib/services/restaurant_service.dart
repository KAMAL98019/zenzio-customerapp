// // lib/services/restaurant_service.dart
// // ⚠️ FALLBACK VERSION - Use this if your backend doesn't have /api/categories endpoint

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../config/api_config.dart';
// import '../data/models/restaurant_model.dart';
// import '../data/models/food_model.dart';

// class RestaurantService {
//   final String baseUrl = ApiConfig.baseUrl;

//   // ✅ Hardcoded category mapping as fallback
//   // TODO: Replace these UUIDs with your actual category IDs from database
//   static const Map<String, String> categoryMapping = {
//     // Format: 'category-uuid': 'Display Name'
//     // 🔹 Add your actual category UUIDs here from the database
//     'a175f7a2-b2ce-435b-a81a-45a26e7aa62f': 'Starters',
//     'b286g8b3-c3df-546c-b92b-56b37f8bb73g': 'Main Course',
//     'c397h9c4-d4eg-657d-c03c-67c48g9cc84h': 'Desserts',
//     'd4a8i0d5-e5fh-768e-d14d-78d59h0dd95i': 'Drinks',
//     'e5b9j1e6-f6gi-879f-e25e-89e60i1ee06j': 'Sides',
//   };

//   Future<List<Restaurant>> fetchRestaurants() async {
//     final url = Uri.parse('$baseUrl${ApiConfig.restaurantsEndpoint}');
//     final response = await http.get(url, headers: ApiConfig.headers);

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       final List<dynamic> data = jsonResponse['data'];
//       return data.map((item) => Restaurant.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to load restaurants');
//     }
//   }

//   Future<Restaurant> fetchRestaurantById(String restaurantId) async {
//     final url = Uri.parse('$baseUrl${ApiConfig.restaurantDetailEndpoint(restaurantId)}');
//     final response = await http.get(url, headers: ApiConfig.headers);

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       return Restaurant.fromJson(jsonResponse['data']);
//     } else {
//       throw Exception('Failed to load restaurant details');
//     }
//   }

//   // Fetch foods for a specific restaurant
//   Future<List<Food>> fetchRestaurantFoods(String restaurantId) async {
//     final url = Uri.parse('$baseUrl/api/restaurants/$restaurantId/foods');
//     final response = await http.get(url, headers: ApiConfig.headers);

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);

//       if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
//         final List<dynamic> data = jsonResponse['data'];
//         return data.map((item) => Food.fromJson(item)).toList();
//       } else {
//         return [];
//       }
//     } else {
//       throw Exception('Failed to load restaurant foods');
//     }
//   }

//   // ✅ Get category name from ID using the mapping
//   String getCategoryName(String? categoryId) {
//     if (categoryId == null || categoryId.isEmpty) {
//       return 'Others';
//     }
//     return categoryMapping[categoryId] ?? 'Others';
//   }

//   // ✅ Group foods by category name (not ID)
//   Map<String, List<Food>> groupFoodsByCategoryName(List<Food> foods) {
//     final Map<String, List<Food>> groupedFoods = {};

//     for (var food in foods) {
//       // Get the category name from the mapping
//       final categoryName = getCategoryName(food.categoryId);

//       if (!groupedFoods.containsKey(categoryName)) {
//         groupedFoods[categoryName] = [];
//       }
//       groupedFoods[categoryName]!.add(food);
//     }

//     // ✅ Sort categories in a logical order
//     final sortedCategories = [
//       'Starters',
//       'Main Course',
//       'Sides',
//       'Desserts',
//       'Drinks',
//       'Others',
//     ];

//     final sortedMap = <String, List<Food>>{};
//     for (var category in sortedCategories) {
//       if (groupedFoods.containsKey(category)) {
//         sortedMap[category] = groupedFoods[category]!;
//       }
//     }

//     // Add any categories not in the sorted list
//     for (var entry in groupedFoods.entries) {
//       if (!sortedMap.containsKey(entry.key)) {
//         sortedMap[entry.key] = entry.value;
//       }
//     }

//     return sortedMap;
//   }

//  Future<Map<String, List<Food>>> fetchRestaurantFoodsWithCategories(String restaurantId) async {
//   if (restaurantId.isEmpty) {
//     print('⚠️ restaurantId is empty. Returning empty list.');
//     return {};
//   }

//   try {
//     final foods = await fetchRestaurantFoods(restaurantId);
//     print('✅ Successfully fetched ${foods.length} foods for $restaurantId');
//     return groupFoodsByCategoryName(foods);
//   } catch (e, stackTrace) {
//     print('💥 Error in fetchRestaurantFoodsWithCategories: $e');
//     print(stackTrace);
//     return {};
//   }
// }

// }

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../data/models/restaurant_model.dart';
import '../data/models/food_model.dart';
import 'api_service.dart';

class RestaurantService {
  final _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  // ✅ Hardcoded category mapping
  static const Map<String, String> categoryMapping = {
    'a175f7a2-b2ce-435b-a81a-45a26e7aa62f': 'Starters',
    'b286g8b3-c3df-546c-b92b-56b37f8bb73g': 'Main Course',
    'c397h9c4-d4eg-657d-c03c-67c48g9cc84h': 'Desserts',
    'd4a8i0d5-e5fh-768e-d14d-78d59h0dd95i': 'Drinks',
    'e5b9j1e6-f6gi-879f-e25e-89e60i1ee06j': 'Sides',
  };

  // ✅ Fetch all restaurants
  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      final response = await _apiService.get(
        ApiConfig.nearestRestaurantsEndpoint,
        requiresAuth: true,
      );

      print('📥 Restaurant API Response: $response');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => Restaurant.fromJson(item)).toList();
    } catch (e) {
      print('❌ Failed to fetch restaurants: $e');
      rethrow;
    }
  }

  // ✅ Fetch single restaurant details by ID
  Future<Restaurant> fetchRestaurantById(String restaurantUid) async {
    try {
      print("🔍 Fetching restaurant details for: $restaurantUid");

      final response = await _apiService.get(
        '/restaurants/$restaurantUid',
        requiresAuth: true,
      );

      print("✅ Restaurant API Response: $response");

      final restaurantData = response["data"]?["restaurant"];

      if (restaurantData == null) {
        throw Exception("No restaurant data found");
      }

      // Extract profile
      final profile = restaurantData['profile'] ?? {};
      final List photos = profile['photo'] ?? [];
      final String imageUrl = photos.isNotEmpty ? photos.first : "";

      // Extract address
      final address = restaurantData['address'] ?? {};
      final String fullAddress = [
        address['address'],
        address['city'],
        address['state'],
        address['pincode'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

      return Restaurant(
        id: restaurantData['uid'] ?? restaurantUid,
        restName: profile['restaurant_name'] ?? 'Unknown',
        restAddress: fullAddress,
        restLogo: imageUrl,
        avgCostTwo: profile['avg_cost_for_two']?.toString() ?? '0',
      );
    } catch (e) {
      print("❌ Failed to fetch restaurant: $e");
      throw Exception("Failed to fetch restaurant: $e");
    }
  }

  // ✅ Fetch all foods of a restaurant (using token)
  Future<List<Food>> fetchRestaurantFoods(String restaurantUid) async {
    try {
      final response = await ApiService().get(
        ApiConfig.getRestaurantMenu(restaurantUid),
        requiresAuth: true,
      );

      print("🍽 API Menu Response: $response");

      // Correct extraction
      final jsonData = response["data"];
      final List<dynamic> menuList = jsonData["restaurant_menus"] ?? [];

      return menuList.map((item) => Food.fromJson(item)).toList();
    } catch (e) {
      print("❌ Failed to fetch foods: $e");
      throw Exception("Failed to fetch foods: $e");
    }
  }

  // ✅ Category utilities
  String getCategoryName(String? categoryId) =>
      categoryMapping[categoryId] ?? 'Others';

  Map<String, List<Food>> groupFoodsByCategoryName(List<Food> foods) {
    final grouped = <String, List<Food>>{};
    for (var food in foods) {
      final name = getCategoryName(food.categoryId);
      grouped.putIfAbsent(name, () => []).add(food);
    }
    return grouped;
  }

  // ✅ Fetch & group foods
  Future<Map<String, List<Food>>> fetchRestaurantFoodsWithCategories(
    String restaurantId,
  ) async {
    if (restaurantId.isEmpty) return {};
    final foods = await fetchRestaurantFoods(restaurantId);
    return groupFoodsByCategoryName(foods);
  }
}
