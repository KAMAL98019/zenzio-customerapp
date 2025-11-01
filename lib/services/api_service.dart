// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  // Set auth token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Get auth token
  String? get authToken => _authToken;

  // Get headers
  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    final headers = Map<String, String>.from(ApiConfig.headers);
    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Handle response
  Future<dynamic> _handleResponse(http.Response response) async {
    final statusCode = response.statusCode;
    
    try {
      // Handle empty response
      if (response.body.isEmpty) {
        if (statusCode >= 200 && statusCode < 300) {
          return {'success': true};
        }
      }

      final body = json.decode(response.body);

      // Success responses
      if (statusCode >= 200 && statusCode < 300) {
        return body;
      }
      
      // Error responses
      final errorMessage = body['message'] ?? 
                         body['error'] ?? 
                         body['detail'] ??
                         'An error occurred';
      
      throw ApiException(
        errorMessage,
        statusCode: statusCode,
        errors: body['errors'] ?? body['data'],
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      
      throw ApiException(
        'Failed to process response: ${e.toString()}',
        statusCode: statusCode,
      );
    }
  }

  // ==================== GET REQUEST ====================
  Future<dynamic> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);

      print('🌐 GET: $uri');

      final response = await http
          .get(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
          )
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on TimeoutException {
      throw ApiException('Request timeout');
    } on http.ClientException {
      throw ApiException('Connection failed');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // ==================== POST REQUEST ====================
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      print('🌐 POST: $uri');
      print('📤 Body: ${json.encode(body)}');

      final response = await http
          .post(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on TimeoutException {
      throw ApiException('Request timeout');
    } on http.ClientException {
      throw ApiException('Connection failed');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // ==================== PUT REQUEST ====================
  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      print('🌐 PUT: $uri');
      print('📤 Body: ${json.encode(body)}');

      final response = await http
          .put(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on TimeoutException {
      throw ApiException('Request timeout');
    } on http.ClientException {
      throw ApiException('Connection failed');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // ==================== PATCH REQUEST ====================
  Future<dynamic> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      print('🌐 PATCH: $uri');
      print('📤 Body: ${json.encode(body)}');

      final response = await http
          .patch(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on TimeoutException {
      throw ApiException('Request timeout');
    } on http.ClientException {
      throw ApiException('Connection failed');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // ==================== DELETE REQUEST ====================
  Future<dynamic> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      print('🌐 DELETE: $uri');

      final response = await http
          .delete(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
          )
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on TimeoutException {
      throw ApiException('Request timeout');
    } on http.ClientException {
      throw ApiException('Connection failed');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // ==================== SAVE TOKEN ====================
  Future<void> saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // ==================== LOAD TOKEN ====================
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // ==================== CLEAR TOKEN ====================
  Future<void> clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}

// Add TimeoutException if not imported
class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Operation timed out']);
  
  @override
  String toString() => message;
}