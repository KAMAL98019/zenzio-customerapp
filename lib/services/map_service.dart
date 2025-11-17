import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:zenzio_customer/services/auth_service.dart';
import '../config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MapService {
  final storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  String getPlatform() {
    if (Platform.isAndroid) return "android";
    if (Platform.isIOS) return "ios";
    return "unknown";
  }

  /// Get nearby restaurants with automatic token refresh
  Future<Map<String, dynamic>> getNearbyRestaurants(
    double lat,
    double lng, {
    int retryCount = 0,
  }) async {
    const maxRetries = 1;

    try {
      // Validate token exists
      String? token = await storage.read(key: 'auth_token');

      if (token == null || token.isEmpty) {
        print('❌ No token found in secure storage');
        
        // Try to check if user is logged in via AuthService
        if (!_authService.isLoggedIn) {
          throw Exception("Please log in to view nearby restaurants");
        }
        
        // Try to get token again after small delay
        await Future.delayed(const Duration(milliseconds: 100));
        token = await storage.read(key: 'auth_token');
        
        if (token == null || token.isEmpty) {
          throw Exception("Authentication token not found. Please login again.");
        }
      }

      // Build URL with /api prefix
      final url = Uri.parse(
        "${ApiConfig.baseUrl}${ApiConfig.nearestRestaurantsEndpoint}?lat=$lat&lng=$lng"
      );

      print("🌐 Fetching nearby restaurants: $url");
      print("🔐 Using token: ${token.substring(0, 20)}...");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "true",
          "platform": getPlatform(),
          "User-Agent": getPlatform(),
          "mode": "development",
          "clientId": ApiConfig.clientId,
        },
      ).timeout(const Duration(seconds: 15));

      print("📥 Response Status: ${response.statusCode}");

      // Success
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Nearby restaurants loaded successfully");
        return data;
      }

      // Token expired - attempt refresh once
      if (response.statusCode == 401 && retryCount < maxRetries) {
        print("⚠️ Token expired (401) - attempting refresh...");

        final refreshed = await _authService.refreshToken();

        if (!refreshed) {
          throw Exception(
            "Session expired and could not be refreshed. Please login again.",
          );
        }

        // Wait for token to be written to storage
        await Future.delayed(const Duration(milliseconds: 200));

        // Retry the request once
        print("🔄 Retrying request with new token...");
        return await getNearbyRestaurants(lat, lng, retryCount: retryCount + 1);
      }

      // Other error codes
      final errorBody = response.body.isNotEmpty 
          ? jsonDecode(response.body) 
          : {'message': 'Unknown error'};
      
      throw Exception(
        errorBody['message'] ?? "Failed to fetch restaurants: ${response.statusCode}",
      );
    } on SocketException {
      print("❌ Network error");
      throw Exception("No internet connection. Please check your network.");
    } on http.ClientException catch (e) {
      print("❌ HTTP client error: $e");
      throw Exception("Network error. Please try again.");
    } on FormatException catch (e) {
      print("❌ JSON parsing error: $e");
      throw Exception("Invalid response from server.");
    } catch (e) {
      print("❌ Error fetching nearby restaurants: $e");
      rethrow;
    }
  }
}