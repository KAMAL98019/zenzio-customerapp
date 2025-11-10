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

// lib/services/restaurant_service.dart
// 
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
        ApiConfig.restaurantsEndpoint,
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
  Future<Restaurant> fetchRestaurantById(String id) async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please log in again.');
    }

    print('🔐 Using token for fetchRestaurantById: $token');

final url = Uri.parse('${ApiConfig.baseUrl}/api/restaurants/$id');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    print('📥 fetchRestaurantById: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Restaurant.fromJson(jsonData['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized (401) — Invalid or expired token.');
    } else {
      throw Exception('Failed to load restaurant: ${response.body}');
    }
  }

  // ✅ Fetch all foods of a restaurant (using token)
  Future<List<Food>> fetchRestaurantFoods(String restaurantId) async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please log in again.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/restaurants/$restaurantId/foods');
    print('🌐 Fetching foods from: $url');
    print('🔐 Using token: $token');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    print('📥 fetchRestaurantFoods: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> data = jsonData['data'] ?? [];
      return data.map((item) => Food.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized (401) — Invalid or expired token.');
    } else {
      throw Exception('Failed to load foods: ${response.body}');
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
      String restaurantId) async {
    if (restaurantId.isEmpty) return {};
    final foods = await fetchRestaurantFoods(restaurantId);
    return groupFoodsByCategoryName(foods);
  }
}
