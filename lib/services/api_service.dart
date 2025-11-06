import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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

  // Get headers (No token logic now)
  Map<String, String> _getHeaders() {
    return Map<String, String>.from(ApiConfig.headers);
  }

  // Handle response
  Future<dynamic> _handleResponse(http.Response response) async {
    final statusCode = response.statusCode;

    try {
      if (response.body.isEmpty) {
        if (statusCode >= 200 && statusCode < 300) {
          return {'success': true};
        }
      }

      final body = json.decode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        return body;
      }

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

  // ==================== GET ====================
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters, required bool requiresAuth,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);

      print('🌐 GET: $uri');
      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // ==================== POST ====================
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body, required bool requiresAuth,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      print('🌐 POST: $uri');
      print('📤 Body: ${json.encode(body)}');

      final response = await http
          .post(uri, headers: _getHeaders(), body: json.encode(body))
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // ==================== PUT ====================
  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body, required bool requiresAuth, required Map<String, String> data,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      print('🌐 PUT: $uri');
      print('📤 Body: ${json.encode(body)}');

      final response = await http
          .put(uri, headers: _getHeaders(), body: json.encode(body))
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // ==================== MULTIPART ====================
  Future<dynamic> multipartRequest(
    String endpoint, {
    required String method,
    Map<String, String>? fields,
    Map<String, File>? files, required bool requiresAuth,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest(method, uri);

      request.headers.addAll(_getHeaders());

      if (fields != null) request.fields.addAll(fields);

      if (files != null) {
        for (var entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      print('🌐 MULTIPART: $uri');
      final streamedResponse =
          await request.send().timeout(ApiConfig.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } catch (e) {
      throw ApiException('Multipart request failed: ${e.toString()}');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Operation timed out']);
  @override
  String toString() => message;
}
