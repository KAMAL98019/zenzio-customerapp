import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://backend.zenzio.in";

  // 🔹 Fetch Categories
  static Future<List<dynamic>> getCategories() async {
    final url = Uri.parse("$baseUrl/api/categories");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["success"] == true && body["data"] is List) {
        return body["data"];
      } else {
        throw Exception("Invalid category response format");
      }
    } else {
      throw Exception("Failed to load categories");
    }
  }

  // 🔹 Fetch Food Items
  static Future<List<dynamic>> getFoodItems({
    String? restaurantId,
    String? cuisineId,
    bool? veg,
    String? search,
  }) async {
    final queryParams = {
      if (restaurantId != null) 'restaurantId': restaurantId,
      if (cuisineId != null) 'cuisineId': cuisineId,
      if (veg != null) 'veg': veg.toString(),
      if (search != null) 'search': search,
    };

    final url = Uri.parse(
      "$baseUrl/api/food-items",
    ).replace(queryParameters: queryParams);
    final response = await http.get(url);

    print("🍽️ Food items response: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["success"] == true && body["data"] is List) {
        return body["data"];
      } else {
        throw Exception("Invalid food items response format");
      }
    } else {
      throw Exception("Failed to load food items");
    }
  }

  // 🔹 Add to Cart
  static Future<Map<String, dynamic>> addToCart(
    Map<String, dynamic> item,
  ) async {
    final url = Uri.parse("$baseUrl/api/carts/items");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(item),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add to cart: ${response.body}");
    }
  }

  // 🔹 Get Addresses
  static Future<List<dynamic>> getAddresses(String userId) async {
    final url = Uri.parse("$baseUrl/api/addresses/$userId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["success"] == true && body["data"] is List) {
        return body["data"];
      } else {
        throw Exception("Invalid address response format");
      }
    } else {
      throw Exception("Failed to load addresses");
    }
  }

  // 🔹 Add Address
  static Future<Map<String, dynamic>> addAddress(
    Map<String, dynamic> address,
  ) async {
    final url = Uri.parse("$baseUrl/api/addresses");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(address),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add address: ${response.body}");
    }
  }

  // 🔹 Fetch Bookings
  static Future<Map<String, dynamic>> getBookings(String userId) async {
    final url = Uri.parse("$baseUrl/api/customer/bookings").replace(
      queryParameters: {'userId': userId},
    );
    final response = await http.get(url);

    print("🗓️ Bookings response: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["success"] == true && body["data"] is Map) {
        return body["data"];
      } else {
        throw Exception("Invalid bookings response format");
      }
    } else {
      throw Exception("Failed to load bookings: ${response.body}");
    }
  }

  // 🔹 Update User Profile
  static Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, String> data,
    String? imagePath,
  ) async {
    final url = Uri.parse("$baseUrl/api/users/$userId");
    final request = http.MultipartRequest('PUT', url);

    request.fields.addAll(data);

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profilePhoto',
        imagePath,
      ));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception("Failed to update profile: $responseBody");
    }
  }

  // 🔹 Update Address
  static Future<Map<String, dynamic>> updateAddress(
    String addressId,
    Map<String, dynamic> address,
  ) async {
    final url = Uri.parse("$baseUrl/api/addresses/$addressId");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(address),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update address: ${response.body}");
    }
  }

  // 🔹 Get User
  static Future<Map<String, dynamic>> getUser(String userId) async {
    final url = Uri.parse("$baseUrl/api/users/$userId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["success"] == true && body["data"] is Map) {
        return body["data"];
      } else {
        throw Exception("Invalid user response format");
      }
    } else {
      throw Exception("Failed to load user");
    }
  }

  // 🔹 Delete Address
  static Future<void> deleteAddress(String addressId) async {
    final url = Uri.parse("$baseUrl/api/addresses/$addressId");
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to delete address: ${response.body}");
    }
  }
}
