import 'dart:convert';
import 'package:customer_app/services/storage_service.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://backend.zenzio.in";

  // ✅ Email Login
  static Future<Map<String, dynamic>> loginWithEmail(
      String email, String password) async {
    final url = Uri.parse("$baseUrl/api/users/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "emailOrMobile": email,
        "password": password,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final userId = responseData['data']['id'];
      // print(userId);
      await StorageService.saveUserId(userId);
      return responseData;
    } else {
      print("1 ${response.body}");
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? "Failed to login");
    }
  }

  // ✅ Register User
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String mobile,
    String? birthday,
    String? anniversary,
  }) async {
    final url = Uri.parse("$baseUrl/api/users");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "mobile": mobile,
        "birthday": birthday ?? "", 
        "anniversary": anniversary ?? "", 
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to register: ${response.body}");
    }
  }
}
