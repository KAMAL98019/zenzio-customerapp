import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:zenzio_customer/data/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String addToCartUrl = "https://backend.zenzio.in/api/cart/items";

  Future<bool> addToCart(CartItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) throw Exception("User not logged in");

      final body = {
        "userId": userId,
        "foodId": item.foodId,
        "quantity": item.quantity,
        "selectedAddOns": item.selectedAddOns
            .map((addon) => {"name": addon.name, "price": addon.price})
            .toList(),
      };

      final response = await http.post(
        Uri.parse(addToCartUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('⬅️ AddToCart Response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Add to cart error: $e');
      return false;
    }
  }
}
