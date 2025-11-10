import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class BookingService {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'https://backend.zenzio.in/api/customer';

  /// Fetch restaurants with token authentication
  Future<List<dynamic>> fetchRestaurants() async {
    try {
      final token = await _storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Missing authentication token. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/restaurants'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'] ?? [];
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — Invalid or expired token.');
      } else {
        throw Exception('Failed to load restaurants. (${response.statusCode})');
      }
    } catch (e) {
      print('❌ BookingService Error: $e');
      rethrow;
    }
  }
}
