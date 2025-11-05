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
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../data/models/restaurant_model.dart';
import '../data/models/food_model.dart';

class RestaurantService {
  final String baseUrl = ApiConfig.baseUrl;

  // ✅ Hardcoded category mapping as fallback
  static const Map<String, String> categoryMapping = {
    'a175f7a2-b2ce-435b-a81a-45a26e7aa62f': 'Starters',
    'b286g8b3-c3df-546c-b92b-56b37f8bb73g': 'Main Course',
    'c397h9c4-d4eg-657d-c03c-67c48g9cc84h': 'Desserts',
    'd4a8i0d5-e5fh-768e-d14d-78d59h0dd95i': 'Drinks',
    'e5b9j1e6-f6gi-879f-e25e-89e60i1ee06j': 'Sides',
  };

  Future<List<Restaurant>> fetchRestaurants() async {
    final url = Uri.parse('$baseUrl${ApiConfig.restaurantsEndpoint}');
    final response = await http.get(url, headers: ApiConfig.headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<Restaurant> fetchRestaurantById(String restaurantId) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.restaurantDetailEndpoint(restaurantId)}');
      print('🌐 Fetching restaurant details from: $url');
      
      final response = await http.get(url, headers: ApiConfig.headers);
      
      print('📥 Restaurant detail API Response: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // ✅ Handle different response structures
        Map<String, dynamic>? restaurantData;
        
        // Try different response structures
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
            restaurantData = jsonResponse['data'] as Map<String, dynamic>;
          } else if (jsonResponse.containsKey('restaurant')) {
            restaurantData = jsonResponse['restaurant'] as Map<String, dynamic>;
          } else if (jsonResponse.containsKey('id') || jsonResponse.containsKey('_id')) {
            // The response itself is the restaurant object
            restaurantData = jsonResponse;
          }
        }

        if (restaurantData == null) {
          print('❌ Could not find restaurant data in response');
          print('📦 Response structure: ${jsonResponse.keys.toList()}');
          throw Exception('Invalid response format: no restaurant data found');
        }

        print('✅ Restaurant data found: ${restaurantData['rest_name']}');
        return Restaurant.fromJson(restaurantData);
        
      } else if (response.statusCode == 404) {
        throw Exception('Restaurant not found');
      } else {
        throw Exception('Failed to load restaurant details: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in fetchRestaurantById: $e');
      rethrow;
    }
  }

  // Fetch foods for a specific restaurant
  Future<List<Food>> fetchRestaurantFoods(String restaurantId) async {
    try {
      final url = Uri.parse('$baseUrl/api/restaurants/$restaurantId/foods');
      print('🌐 Fetching foods from: $url');
      
      final response = await http.get(url, headers: ApiConfig.headers);
      
      print('📥 Foods API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          print('✅ Found ${data.length} foods');
          return data.map((item) => Food.fromJson(item)).toList();
        } else {
          print('⚠️ No foods found in response');
          return [];
        }
      } else {
        print('❌ Foods API failed with status: ${response.statusCode}');
        throw Exception('Failed to load restaurant foods');
      }
    } catch (e) {
      print('❌ Error fetching foods: $e');
      rethrow;
    }
  }

  // ✅ Get category name from ID using the mapping
  String getCategoryName(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return 'Others';
    }
    return categoryMapping[categoryId] ?? 'Others';
  }

  // ✅ Group foods by category name (not ID)
  Map<String, List<Food>> groupFoodsByCategoryName(List<Food> foods) {
    final Map<String, List<Food>> groupedFoods = {};

    for (var food in foods) {
      // Get the category name from the mapping
      final categoryName = getCategoryName(food.categoryId);
      
      if (!groupedFoods.containsKey(categoryName)) {
        groupedFoods[categoryName] = [];
      }
      groupedFoods[categoryName]!.add(food);
    }

    // ✅ Sort categories in a logical order
    final sortedCategories = [
      'Starters',
      'Main Course',
      'Sides',
      'Desserts',
      'Drinks',
      'Others',
    ];

    final sortedMap = <String, List<Food>>{};
    for (var category in sortedCategories) {
      if (groupedFoods.containsKey(category)) {
        sortedMap[category] = groupedFoods[category]!;
      }
    }

    // Add any categories not in the sorted list
    for (var entry in groupedFoods.entries) {
      if (!sortedMap.containsKey(entry.key)) {
        sortedMap[entry.key] = entry.value;
      }
    }

    return sortedMap;
  }

  Future<Map<String, List<Food>>> fetchRestaurantFoodsWithCategories(String restaurantId) async {
    if (restaurantId.isEmpty) {
      print('⚠️ restaurantId is empty. Returning empty map.');
      return {};
    }

    try {
      final foods = await fetchRestaurantFoods(restaurantId);
      print('✅ Successfully fetched ${foods.length} foods for $restaurantId');
      return groupFoodsByCategoryName(foods);
    } catch (e, stackTrace) {
      print('💥 Error in fetchRestaurantFoodsWithCategories: $e');
      print(stackTrace);
      return {};
    }
  }
}