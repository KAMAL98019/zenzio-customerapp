import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../data/models/login_response.dart';
import '../data/models/register_response.dart';
import '../data/models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _apiService = ApiService();
  final storage = const FlutterSecureStorage();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ==================== INITIALIZE ====================
  Future<void> initialize() async {
    try {
      final userData = await storage.read(key: 'user_data');
      if (userData != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
        print('✅ Auto logged in as: ${_currentUser?.name}');
      } else {
        print('⚠️ No user data found in SecureStorage');
      }
    } catch (e) {
      print('❌ Initialization error: $e');
    }
  }


// ✅ Email check helper
  bool _isEmail(String input) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(input);
  }


  // ==================== REGISTER ====================
  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String countryCode,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'mobile': phone ?? '',
      };

      final response = await _apiService.post(
        ApiConfig.signupEndpoint,
        body: body,
        requiresAuth: false,
      );

      final registerResponse = RegisterResponse.fromJson(response);
      _currentUser = registerResponse.user;

      // ✅ Save token securely
      final token = response['token'] ?? response['data']?['token'];
      if (token != null && token.toString().isNotEmpty) {
        await storage.write(key: 'auth_token', value: token.toString());
        print('🔐 Token saved securely');
      }

      await storage.write(
          key: 'user_data', value: jsonEncode(_currentUser!.toJson()));

      return registerResponse;
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

Future<void> sendEmailVerification() async {
  try {
    final response = await _apiService.post(
      ApiConfig.firebaseSendVerificationEndpoint,
      body: {}, // no body needed
      requiresAuth: true, // user must be logged in
    );

    if (response['success'] == true || response['status'] == 201) {
      print('📩 Verification email sent successfully');
    } else {
      print('⚠️ Failed to send verification email: ${response['message']}');
    }
  } catch (e) {
    print('❌ Error sending verification email: $e');
  }
}



  // ==================== LOGIN ====================
  Future<LoginResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        body: {'emailOrMobile': email, 'password': password},
        requiresAuth: false,
      );

      print('📥 Login Response: $response');

      if (response['success'] == true && response['data'] != null) {
        final userJson = Map<String, dynamic>.from(response['data']);

        // ✅ Extract token
        final token = response['token'] ?? userJson['token'];
        print('✅ Token: $token');

        // ✅ Fix profile photo URL
        if (userJson['profilePhoto'] != null &&
            userJson['profilePhoto'].toString().isNotEmpty &&
            !userJson['profilePhoto'].toString().startsWith('http')) {
          userJson['profilePhoto'] =
              'https://backend.zenzio.in${userJson['profilePhoto']}';
        }

        final user = User.fromJson(userJson);
        _currentUser = user;

        // ✅ Save securely
        await storage.write(key: 'auth_token', value: token ?? '');
        await storage.write(key: 'user_id', value: user.id ?? '');
        await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));

        print('✅ Login successful: ${user.name}');
        return LoginResponse(user: user, message: 'Login successful');
      } else {
        throw ApiException(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  
Future<void> sendOTP({
  required String phone,
  required String countryCode,
}) async {
  try {
    final response = await _apiService.post(
      ApiConfig.otpSendEndpoint, // ✅ define in your ApiConfig
      body: {
        'mobile': phone,
        'countryCode': countryCode,
      },
      requiresAuth: false,
    );

    if (response['success'] == true) {
      print('✅ OTP sent successfully to $countryCode$phone');
    } else {
      throw Exception(response['message'] ?? 'Failed to send OTP');
    }
  } catch (e) {
    print('❌ OTP send error: $e');
    rethrow;
  }
}

  /// Verifies the OTP 
Future<Map<String, dynamic>> verifyOTP({
    required String phone,
    required String countryCode,
    required String otp,
  }) async {
    final uri = Uri.parse(ApiConfig.otpVerifyEndpoint); 
    try {
      final response = await http.post(
        uri,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({
          'mobile': phone,
          'countryCode': countryCode,
          'otp': otp,
        }),
      );

      // Debug
      print('🔹 verifyOTP (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // If backend returned a token/user, store them securely
        final token = data['token'] ?? data['data']?['token'];
        final userJson = data['user'] ?? data['data']?['user'] ?? data['data'];

        if (token != null && token.toString().isNotEmpty) {
          await storage.write(key: 'auth_token', value: token.toString());
          print('🔐 auth_token saved');
        }

        if (userJson != null) {
          try {
            // Save user id and full user data if possible
            final Map<String, dynamic> uj = userJson is String
                ? jsonDecode(userJson)
                : Map<String, dynamic>.from(userJson);
            if (uj['id'] != null) {
              await storage.write(key: 'user_id', value: uj['id'].toString());
            }
            await storage.write(key: 'user_data', value: jsonEncode(uj));
            print('👤 user_data saved');
          } catch (e) {
            print('⚠️ Could not parse/save user data: $e');
          }
        }

        return data;
      } else if (response.statusCode == 404) {
        throw ApiException('User not found. Please sign up.');
      } else {
        // Backend might still return JSON error; try decode to show message
        try {
          final err = jsonDecode(response.body);
          final msg = err['message'] ?? err['error'] ?? 'Failed to verify OTP';
          throw ApiException(msg.toString());
        } catch (_) {
          throw ApiException('Failed to verify OTP. (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ verifyOTP error: $e');
      throw ApiException('Unable to verify OTP. Please try again.');
    }
  }

  /// Wrapper around existing sendOTP to use for resending.
  /// Returns backend response map.
  Future<Map<String, dynamic>> resendOTP({
    required String phone,
    required String countryCode,
  }) async {
    final uri = Uri.parse(ApiConfig.otpSendEndpoint);
    try {
      final response = await http.post(
        uri,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({
          'mobile': phone,
          'countryCode': countryCode,
        }),
      );

      print('🔹 resendOTP (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        try {
          final err = jsonDecode(response.body);
          throw ApiException(err['message'] ?? 'Failed to resend OTP');
        } catch (_) {
          throw ApiException('Failed to resend OTP. (${response.statusCode})');
        }
      }
    } catch (e) {
      print('❌ resendOTP error: $e');
      throw ApiException('Unable to resend OTP. Please try again.');
    }
  }


 // ==================== SEND FORGOT PASSWORD OTP ====================
 Future<Map<String, dynamic>> sendForgotPasswordOTP(String email) async {
    try {
      final trimmed = email.trim();

      if (trimmed.isEmpty) {
        return {
          'success': false,
          'message': 'Please enter your email address.',
        };
      }

      // ✅ Body only has email
      final Map<String, dynamic> body = {'emailOrMobile': trimmed};

      print('📤 Sending forgot password OTP with body: $body');

      final response = await _apiService.post(
        ApiConfig.forgotPasswordEndpoint,
        body: body,
        requiresAuth: false,
      );

      print('📥 Response: $response');

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'OTP sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      print('❌ sendForgotPasswordOTP error: $e');
      return {
        'success': false,
        'message': 'Something went wrong: ${e.toString()}',
      };
    }
  }

 // ==================== VERIFY FORGOT PASSWORD OTP ====================
Future<Map<String, dynamic>> verifyForgotPasswordOTP({
  required String input,
  required String otp,
}) async {
  try {
    final bool isEmail = _isEmail(input.trim());
    final Map<String, dynamic> body = isEmail
        ? {'email': input.trim(), 'otp': otp.trim()}
        : {
            'mobile': input.trim(),
            'countryCode': '+91',
            'otp': otp.trim(),
          };

    final response = await _apiService.post(
      ApiConfig.resetPasswordEndpoint,
      body: body,
      requiresAuth: false,
    );

    if (response['success'] == true) {
      return {
        'success': true,
        'message': response['message'] ?? 'OTP verified successfully',
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Invalid or expired OTP',
      };
    }
  } catch (e) {
    print('❌ verifyForgotPasswordOTP error: $e');
    return {
      'success': false,
      'message': 'Something went wrong: ${e.toString()}',
    };
  }
}

  




  // ==================== GET USER PROFILE ====================
  Future<User> getUserProfile() async {
    try {
      final token = await storage.read(key: 'auth_token');
      final userId = await storage.read(key: 'user_id');

      if (token == null || userId == null) {
        throw Exception('Missing authentication token or user ID');
      }

      final response = await _apiService.get(
        '${ApiConfig.userProfileEndpoint}/$userId',
        requiresAuth: true,
      );

      _currentUser = User.fromJson(response['data'] ?? response);

      await storage.write(
          key: 'user_data', value: jsonEncode(_currentUser!.toJson()));

      print('✅ User profile fetched successfully');
      return _currentUser!;
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      rethrow;
    }
  }

  // ==================== UPDATE PROFILE ====================
 Future<void> updateProfileWithImage({
  required String name,
  required String email,
  String? password,
  String? birthday,
  String? anniversary,
  File? profilePhoto,
}) async {
  try {
    final token = await storage.read(key: 'auth_token');
    final userId = await storage.read(key: 'user_id');

    if (userId == null || token == null || token.isEmpty) {
      throw Exception('Missing authentication credentials. Please login again.');
    }

    final fields = {
      'name': name,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (birthday != null) 'birthday': birthday,
      if (anniversary != null) 'anniversary': anniversary,
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/$userId');
    final request = http.MultipartRequest('PUT', uri);

    // ✅ Add Authorization header
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // ✅ Add text fields
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // ✅ Add file if exists
    if (profilePhoto != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profilePhoto',
        profilePhoto.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userJson = data['user'] ?? data['data'] ?? data;
      final updatedUser = User.fromJson(Map<String, dynamic>.from(userJson));

      await storage.write(
        key: 'user_data',
        value: jsonEncode(updatedUser.toJson()),
      );
      _currentUser = updatedUser;

      print('✅ Profile updated successfully');
    } else {
      print('❌ Failed with status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');
      throw Exception('Multipart request failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error updating profile: $e');
    rethrow;
  }
}


  // ==================== LOGOUT ====================
  Future<void> logout() async {
    await storage.deleteAll();
    _currentUser = null;
    print('🚪 Logged out successfully');
  }
}
