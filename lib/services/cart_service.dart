import 'package:zenzio_customer/services/api_service.dart';
import 'package:zenzio_customer/services/restaurant_service.dart';
import '../data/models/cart_model.dart';
import '../config/api_config.dart';

class CartService {
  final ApiService _api = ApiService();

  // ============================
  // 1. FETCH FULL CART
  // ============================
  Future<List<CartItem>> fetchCartItems() async {
    final response =
        await _api.get(ApiConfig.cartEndpoint, requiresAuth: true);

    print("🛒 FULL CART RESPONSE => $response");

    if (response["data"] == null || response["data"]["cart"] == null) return [];

    final items = response["data"]["cart"]["items"] ?? [];

    return items.map((e) => CartItem.fromJson(e)).toList();
  }

  // ============================
  // 2. ADD ITEM TO CART
  // ============================
Future<void> addToCart(CartItem item) async {
  final body = {
    "restaurant_uid":item.restaurantUid,
    "menu_uid": item.menuUid.toString(),
  "menu_name": item.menuName,
  "price": item.price.toDouble(),
  "qty": item.qty

  

    // "foodId": item.foodId,
    // "quantity": item.quantity,
    // "selectedAddOns": item.selectedAddOns
    //     .map((a) => {"name": a.name, "price": a.price})
    //     .toList(),
  };

  print("🛒 AddToCart Request => $body");

  try {
    final response = await _api.post(
      ApiConfig.addToCartEndpoint,
      body: body,
      requiresAuth: true,
    );

    print("🛒 AddToCart Response => $response");

    // Optionally check for backend errors
    if (response == null) {
      throw Exception("No response from server");
    }
    if (response['error'] != null) {
      throw Exception(response['error']);
    }

  } on ApiException catch (e) {
    // If your _api.post throws ApiException
    print("❌ API Error: ${e.message} (Status: ${e.statusCode})");
    rethrow; // pass it to the UI for SnackBar
  } catch (e) {
    // Network or unexpected errors
    print("❌ Add to cart failed: $e");
    rethrow; // pass it to UI
  }
}

// ============================
//  GET ITEMS BY RESTAURANT
// URL → /cart/restaurant/:id/items
// ============================
Future<List<dynamic>> fetchRestaurantItems(String restaurantId) async {
  final endpoint = ApiConfig.restaurantItemsEndpoint(restaurantId); 
  final response = await _api.get(endpoint, requiresAuth: true);

  print("🍽 Restaurant Items => $response");

  return response["data"]?["items"] ?? [];
}

 // ============================
  // ✅ NEW: GET CART DETAILS WITH cart_group_uid
  // URL → /cart/restaurant/:id
  // ============================
  Future<Map<String, dynamic>> getCartDetails(String restaurantId) async {
    final endpoint = ApiConfig.restaurantItemsEndpoint(restaurantId);
    final response = await _api.get(endpoint, requiresAuth: true);

    print("🍽 Cart Details => $response");

    // Return the entire data object which includes cart_group_uid
    return response["data"] ?? {};
  }

  // ============================
  //  UPDATE CART ITEM QUANTITY
  // URL → /cart/item/:id
  // ============================
Future<void> updateItemQuantity(String itemId, int quantity) async {
  final body = { "qty": quantity };

  final response = await _api.patch(
    "${ApiConfig.updateCartQtyEndpoint}/$itemId",
    body: body,
    requiresAuth: true,
  );

  print("🔄 Update Quantity => $response");
}

  // ============================
  // 4. REMOVE ITEM FROM CART
  // URL → /cart/item/:idz
  // ============================
 Future<void> removeCartItem(String itemId) async {
  final response = await _api.delete(
    "${ApiConfig.removeCartItemEndpoint}/$itemId",
    requiresAuth: true,
  );

  print("❌ Remove Cart Item => $response");
}

  // ============================
  // 5. CLEAR CART (ALL RESTAURANTS)
  // ============================
  Future<void> clearCart() async {
    final response = await _api.post(
      ApiConfig.clearCartEndpoint,
      body: {},
      requiresAuth: true,
    );

    print("🗑 Clear Cart => $response");
  }
// ============================
  // ✅ NEW: GET CART GROUP BY RESTAURANT UID
  // URL → /cart/group/:restaurantUid
  // ============================
  Future<Map<String, dynamic>> getCartGroup(String restaurantUid) async {
    final endpoint = ApiConfig.getCartGroup(restaurantUid);
    final response = await _api.get(endpoint, requiresAuth: true);

    print("🍽 Cart Group => $response");

    return response["data"] ?? {};
  }
  // ============================
  // 6. CLEAR SPECIFIC RESTAURANT CART GROUP
  // URL → /cart/group/:restId
  // ============================
  Future<void> clearRestaurantCart(String restaurantId) async {
    final response = await _api.delete(
      "${ApiConfig.clearRestCartEndpoint}/$restaurantId",
      requiresAuth: true,
    );

    print("🗑 Clear Restaurant Cart => $response");
  }


// In cart_service.dart
// Future<Map<String, dynamic>> getCartDetailsWithRestaurant(String restaurantId) async {
//   try {
//     // Get cart details
//     final cartDetails = await getCartDetails(restaurantId);
    
//     // Fetch restaurant info separately
//     final restaurantService = RestaurantService();
//     final restaurant = await restaurantService.fetchRestaurantById(restaurantId);
    
//     // Combine both
//     cartDetails['restaurant'] = {
//       'restaurant_name': restaurant.restName,
//       'restaurant_uid': restaurant.id,
//       'rest_address': restaurant.restAddress,
//       'rest_logo': restaurant.restLogo,
//     };
    
//     return cartDetails;
//   } catch (e) {
//     print('❌ Error getting cart with restaurant: $e');
//     rethrow;
//   }
// }

}

//main import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../data/models/cart_model.dart';
// import 'token_service.dart';

// class CartService {
//   static const String baseUrl = "https://backend.zenzio.in/api/cart";
//   final TokenService _tokenService = TokenService();

//   /// Adds item to cart using token-based auth
// Future<void> addToCart(CartItem item) async {
//   final token = await _tokenService.getToken();
//   final userId = await _tokenService.getUserId(); 

//   if (token == null || userId == null) {
//     throw Exception("User not logged in");
//   }

//   final body = {
//     "userId": userId, 
//     "foodId": item.foodId,
//     "quantity": item.quantity,
//     "selectedAddOns": item.selectedAddOns
//         .map((addon) => {"name": addon.name, "price": addon.price})
//         .toList(),
//   };

//   final response = await http.post(
//     Uri.parse("$baseUrl/items"),
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     },
//     body: jsonEncode(body),
//   );

//   print('🛒 Add to Cart Response: ${response.statusCode} ${response.body}');

//   if (response.statusCode == 200 || response.statusCode == 201) {
//     return; // ✅ Success
//   } else if (response.statusCode == 409) {
//     final data = jsonDecode(response.body);
//     final message = data['message'] ?? 'Cart conflict';
//     throw Exception('DIFFERENT_RESTAURANT: $message');
//   } else {
//     throw Exception('Failed to add item to cart: ${response.body}');
//   }
// }

//   /// Clear cart using token-based auth
//   Future<void> clearCart() async {
//     final token = await _tokenService.getToken();
//     if (token == null) throw Exception("User not logged in");

//     final response = await http.delete(
//       Uri.parse("$baseUrl/clear"),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to clear cart: ${response.body}');
//     }
//   }
// }
  


// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:zenzio_customer/data/models/cart_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CartService {
//   static const String addToCartUrl = "https://backend.zenzio.in/api/cart/items";

//   Future<bool> addToCart(CartItem item) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString('user_id');
//       if (userId == null) throw Exception("User not logged in");

//       final body = {
//         "userId": userId,
//         "foodId": item.foodId,
//         "quantity": item.quantity,
//         "selectedAddOns": item.selectedAddOns
//             .map((addon) => {"name": addon.name, "price": addon.price})
//             .toList(),
//       };

//       final response = await http.post(
//         Uri.parse(addToCartUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );

//       print('⬅️ AddToCart Response: ${response.statusCode} ${response.body}');
//       return response.statusCode == 200 || response.statusCode == 201;
//     } catch (e) {
//       print('❌ Add to cart error: $e');
//       return false;
//     }
//   }
//     /// Clear cart using token-based auth
//   Future<void> clearCart() async {
//   final prefs = await SharedPreferences.getInstance();
//   final userId = prefs.getString('user_id');
//   if (userId == null) throw Exception("User not logged in");

//   final response = await http.delete(
//     Uri.parse("https://backend.zenzio.in/api/cart/clear/$userId"),
//     headers: {'Content-Type': 'application/json'},
//   );

//   if (response.statusCode != 200) {
//     throw Exception('Failed to clear cart: ${response.body}');
//   }
// }

// }

