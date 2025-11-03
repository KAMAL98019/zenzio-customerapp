import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:zenzio_customer/data/models/cart_model.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  get baseUrl => null;
  
  get apiVersion => null;

  Future<bool> addToCart(CartItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId'); // 🧩 stored when login
      if (userId == null) throw Exception("User not logged in");

      // Step 1️⃣: Ensure cart exists
      final ensureResponse = await http.post(
        Uri.parse('$baseUrl$apiVersion/carts/ensure'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "restId": item.restaurantId ?? "YOUR_CURRENT_REST_ID" // pass restaurantId
        }),
      );

      if (ensureResponse.statusCode != 200) {
        print('❌ Failed to ensure cart: ${ensureResponse.body}');
        return false;
      }

      final cartData = jsonDecode(ensureResponse.body);
      final cartId = cartData['cart']['id'] ?? cartData['id'];

      // Step 2️⃣: Add item to that cart
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/carts/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "cartId": cartId,
          "foodId": item.foodId,
          "quantity": item.quantity,
          "selectedAddOns": item.selectedAddOns
              .map((addon) => {"name": addon.name, "price": addon.price})
              .toList(),
        }),
      );

      print('⬅️ AddToCart Response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Add to cart error: $e');
      return false;
    }
  }
}
