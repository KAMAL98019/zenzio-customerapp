import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  final _storage = const FlutterSecureStorage();

  // ==================== HEADERS ====================
  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = Map<String, String>.from(ApiConfig.headers);

    if (requiresAuth) {
      final token = await _storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ==================== HANDLE RESPONSE ====================
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

      // Handle token expiration (401)
      if (statusCode == 401) {
        await _storage.delete(key: 'auth_token');
        throw ApiException(
          'Session expired. Please log in again.',
          statusCode: 401,
        );
      }

      final errorMessage =
          body['message'] ??
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


Future<dynamic> get(
  String endpoint, {
  bool requiresAuth = false,
}) async {
  try {
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    print('🌐 GET: $uri');
    print('📤 Headers: $headers');

    final response = await http
        .get(uri, headers: headers)
        .timeout(ApiConfig.connectTimeout);

    print('📥 Response Status: ${response.statusCode}');
    return _handleResponse(response);
  } catch (e) {
    print('❌ GET error: $e');
    throw ApiException('GET request failed: $e');
  }
}

// ==================== POST ====================
Future<dynamic> post(
  String endpoint, {
  required Map<String, dynamic> body,
  bool requiresAuth = false,
}) async {
  try {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    
    // Add additional headers specific to POST
    headers['platform'] = 'Android';
    headers['User-Agent'] = 'Android';
    headers['mode'] = 'development';
    headers['clientId'] = ApiConfig.clientId;

    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    print('🌐 POST: $uri');
    print('📤 Headers: $headers');
    print('📦 Body: ${jsonEncode(body)}');

    final response = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.connectTimeout);

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    return await _handleResponse(response);
  } catch (e) {
    print('❌ POST error: $e');
    throw ApiException('POST request failed: $e');
  }
}

// ==================== MULTIPART ====================
Future<dynamic> multipartRequest(
  String endpoint, {
  required String method,
  required Map<String, String> fields,
  required Map<String, File> files,
  bool requiresAuth = false,
}) async {
  try {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest(method, uri);

    // ✅ Get headers with token if required
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    request.headers.addAll(headers);

    fields.forEach((key, value) => request.fields[key] = value);
    
    for (final entry in files.entries) {
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value.path),
      );
    }

    print('🌐 MULTIPART $method: $uri');
    print('📤 Headers: ${request.headers}');

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('📥 Response Status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      throw ApiException(
        'Upload failed: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    print('❌ Multipart error: $e');
    throw ApiException('Multipart request failed: $e');
  }
}

  // ==================== GET ====================
  // Future<dynamic> get(
  //   String endpoint, {
  //   bool requiresAuth = false,
  //   String? token, // 👈 add this line
  // }) async {
  //   try {
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
  //     };

  //     final response = await http.get(
  //       Uri.parse('${ApiConfig.baseUrl}$endpoint'),
  //       headers: headers,
  //     );

  //     return _handleResponse(response);
  //   } catch (e) {
  //     throw Exception('GET request failed: $e');
  //   }
  // }

  // // ==================== POST ====================
  // Future<dynamic> post(
  //   String endpoint, {
  //   required Map<String, dynamic> body,
  //   bool requiresAuth = false,
  //   String? token,
  // }) async {
  //   try {
  //     // ✅ Add headers
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'platform': 'Android',
  //       'User-Agent': 'Android', // 👈 add this line
  //       'mode': "development",

  //       'clientId': ApiConfig.clientId,

  //       // 'client-secret': ApiConfig.clientSecret, // temporarily disabled
  //       if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
  //     };

  //     final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

  //     print('🌐 POST: $uri');
  //     print('📤 Headers: $headers');
  //     print('📦 Body: ${jsonEncode(body)}');

  //     final response = await http.post(
  //       uri,
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );

  //     print('📥 Response Status: ${response.statusCode}');
  //     print('📥 Response Body: ${response.body}');

  //     return await _handleResponse(response);
  //   } catch (e) {
  //     print('❌ POST error: $e');
  //     throw ApiException('request failed: $e');
  //   }
  // }

  // ==================== PUT ====================
  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> body,
    required bool requiresAuth,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      print('🌐 PUT: $uri');
      print('📤 Body: ${json.encode(body)}');

      final response = await http
          .put(
            uri,
            headers: await _getHeaders(requiresAuth: requiresAuth),
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response: ${response.statusCode}');
      return await _handleResponse(response);
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // // ==================== MULTIPART ====================
  // Future<dynamic> multipartRequest(
  //   String endpoint, {
  //   required String method,
  //   required Map<String, String> fields,
  //   required Map<String, File> files,
  //   bool requiresAuth = false,
  //   String? token, // 👈 add this
  // }) async {
  //   try {
  //     final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
  //     final request = http.MultipartRequest(method, uri);

  //     // ✅ Add headers
  //     if (requiresAuth && token != null) {
  //       request.headers['Authorization'] = 'Bearer $token';
  //     }

  //     fields.forEach((key, value) => request.fields[key] = value);
  //     for (final entry in files.entries) {
  //       request.files.add(
  //         await http.MultipartFile.fromPath(entry.key, entry.value.path),
  //       );
  //     }

  //     final response = await request.send();
  //     final responseBody = await response.stream.bytesToString();

  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       return jsonDecode(responseBody);
  //     } else {
  //       throw Exception('Failed to upload file: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Multipart request failed: $e');
  //   }
  // }
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import '../config/api_config.dart';

// class ApiException implements Exception {
//   final String message;
//   final int? statusCode;
//   final dynamic errors;

//   ApiException(this.message, {this.statusCode, this.errors});

//   @override
//   String toString() => message;
// }

// class ApiService {
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//   ApiService._internal();

//   // Get headers (No token logic now)
//   Map<String, String> _getHeaders() {
//     return Map<String, String>.from(ApiConfig.headers);
//   }

//   // Handle response
//   Future<dynamic> _handleResponse(http.Response response) async {
//     final statusCode = response.statusCode;

//     try {
//       if (response.body.isEmpty) {
//         if (statusCode >= 200 && statusCode < 300) {
//           return {'success': true};
//         }
//       }

//       final body = json.decode(response.body);

//       if (statusCode >= 200 && statusCode < 300) {
//         return body;
//       }

//       final errorMessage = body['message'] ??
//           body['error'] ??
//           body['detail'] ??
//           'An error occurred';

//       throw ApiException(
//         errorMessage,
//         statusCode: statusCode,
//         errors: body['errors'] ?? body['data'],
//       );
//     } catch (e) {
//       if (e is ApiException) rethrow;
//       throw ApiException(
//         'Failed to process response: ${e.toString()}',
//         statusCode: statusCode,
//       );
//     }
//   }

//   // ==================== GET ====================
//   Future<dynamic> get(
//     String endpoint, {
//     Map<String, String>? queryParameters, required bool requiresAuth,
//   }) async {
//     try {
//       final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
//           .replace(queryParameters: queryParameters);

//       print('🌐 GET: $uri');
//       final response = await http
//           .get(uri, headers: _getHeaders())
//           .timeout(ApiConfig.connectTimeout);

//       print('✅ Response: ${response.statusCode}');
//       return await _handleResponse(response);
//     } catch (e) {
//       throw ApiException('Request failed: ${e.toString()}');
//     }
//   }

//   // ==================== POST ====================
//   Future<dynamic> post(
//     String endpoint, {
//     required Map<String, dynamic> body, required bool requiresAuth,
//   }) async {
//     try {
//       final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
//       print('🌐 POST: $uri');
//       print('📤 Body: ${json.encode(body)}');

//       final response = await http
//           .post(uri, headers: _getHeaders(), body: json.encode(body))
//           .timeout(ApiConfig.connectTimeout);

//       print('✅ Response: ${response.statusCode}');
//       return await _handleResponse(response);
//     } catch (e) {
//       throw ApiException('Request failed: ${e.toString()}');
//     }
//   }

//   // ==================== PUT ====================
//   Future<dynamic> put(
//     String endpoint, {
//     required Map<String, dynamic> body, required bool requiresAuth, required Map<String, String> data,
//   }) async {
//     try {
//       final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
//       print('🌐 PUT: $uri');
//       print('📤 Body: ${json.encode(body)}');

//       final response = await http
//           .put(uri, headers: _getHeaders(), body: json.encode(body))
//           .timeout(ApiConfig.connectTimeout);

//       print('✅ Response: ${response.statusCode}');
//       return await _handleResponse(response);
//     } catch (e) {
//       throw ApiException('Request failed: ${e.toString()}');
//     }
//   }

//   // ==================== MULTIPART ====================
//   Future<dynamic> multipartRequest(
//     String endpoint, {
//     required String method,
//     Map<String, String>? fields,
//     Map<String, File>? files, required bool requiresAuth,
//   }) async {
//     try {
//       final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
//       final request = http.MultipartRequest(method, uri);

//       request.headers.addAll(_getHeaders());

//       if (fields != null) request.fields.addAll(fields);

//       if (files != null) {
//         for (var entry in files.entries) {
//           request.files.add(
//             await http.MultipartFile.fromPath(entry.key, entry.value.path),
//           );
//         }
//       }

//       print('🌐 MULTIPART: $uri');
//       final streamedResponse =
//           await request.send().timeout(ApiConfig.connectTimeout);
//       final response = await http.Response.fromStream(streamedResponse);

//       print('✅ Response: ${response.statusCode}');
//       return await _handleResponse(response);
//     } catch (e) {
//       throw ApiException('Multipart request failed: ${e.toString()}');
//     }
//   }
// }

// class TimeoutException implements Exception {
//   final String message;
//   TimeoutException([this.message = 'Operation timed out']);
//   @override
//   String toString() => message;
// }
