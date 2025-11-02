import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zenzio_customer/data/models/cart_model.dart';
import '../config/api_config.dart';


class CartService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<bool> addToCart(CartItem item) async {
    final url = Uri.parse('$baseUrl${ApiConfig.addToCartEndpoint}');
    
    print("➡️ Sending POST to $url");
    print("📦 Payload: ${jsonEncode(item.toJson())}");

    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode(item.toJson()),
    );

    print("⬅️ Response: ${response.statusCode} ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['success'] == true;
    } else {
      return false;
    }
  }
}
