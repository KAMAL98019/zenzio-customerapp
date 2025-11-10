import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/cart_model.dart';
import 'token_service.dart';

class CartService {
  static const String baseUrl = "https://backend.zenzio.in/api/cart";
  final TokenService _tokenService = TokenService();

  /// Adds item to cart using token-based auth
Future<void> addToCart(CartItem item) async {
  final token = await _tokenService.getToken();
  final userId = await _tokenService.getUserId(); // ✅ Fetch userId

  if (token == null || userId == null) {
    throw Exception("User not logged in");
  }

  final body = {
    "userId": userId, // ✅ Include userId here
    "foodId": item.foodId,
    "quantity": item.quantity,
    "selectedAddOns": item.selectedAddOns
        .map((addon) => {"name": addon.name, "price": addon.price})
        .toList(),
  };

  final response = await http.post(
    Uri.parse("$baseUrl/items"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  print('🛒 Add to Cart Response: ${response.statusCode} ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    return; // ✅ Success
  } else if (response.statusCode == 409) {
    final data = jsonDecode(response.body);
    final message = data['message'] ?? 'Cart conflict';
    throw Exception('DIFFERENT_RESTAURANT: $message');
  } else {
    throw Exception('Failed to add item to cart: ${response.body}');
  }
}

  /// Clear cart using token-based auth
  Future<void> clearCart() async {
    final token = await _tokenService.getToken();
    if (token == null) throw Exception("User not logged in");

    final response = await http.delete(
      Uri.parse("$baseUrl/clear"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart: ${response.body}');
    }
  }
}
  


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

