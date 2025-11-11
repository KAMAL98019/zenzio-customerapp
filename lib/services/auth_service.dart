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
    required String lastName,
    String? phone,
    required String countryCode,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final nameParts = name.trim().split(' ');
      final firstName = nameParts.first;

      final body = {
        'firstName': firstName,
        'lastName': lastName,
        'photo': '',
        'age': '',
        'email': email,
        'phoneNumber': phone ?? '',
        'password': password,
        'bank_details': {
          'bank_name': '',
          'ifsc_code': '',
          'account_number': '',
          'account_type': '',
        },
        'address': {
          'city': '',
          'state': '',
          'pincode': '',
          'address': '',
          'address_secondary': '',
        },
      };

      print('📤 Sending registration with body: $body');

      final response = await _apiService.post(
        ApiConfig.signupEndpoint,
        body: body,
        requiresAuth: false,
      );

      print('📥 Response Body: $response');

      // ✅ Adjust to match your backend response
      final userJson =
          response['fullUser'] ??
          response['data']?['fullUser'] ??
          response['data'] ??
          response;

      if (userJson == null) {
        throw Exception('No user data returned from API');
      }

      _currentUser = User.fromJson(Map<String, dynamic>.from(userJson));

      // ✅ Extract token
      final token =
          response['accessToken'] ??
          response['token'] ??
          response['data']?['token'];

      print('✅ Token: ${response['refreshToken']}');

      if (token != null && token.toString().isNotEmpty) {
        await storage.write(key: 'auth_token', value: token.toString());
        print('🔐 Token saved securely');
      } else {
        print('⚠️ No token found in response');
      }

      // ✅ Save user data securely
      await storage.write(
        key: 'user_data',
        value: jsonEncode(_currentUser!.toJson()),
      );

      return RegisterResponse(
        user: _currentUser!,
        message: 'Registration successful',
      );
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
      final body = {'email': email, 'password': password};

      print('📤 Sending login request with body: $body');

      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        body: body,
        requiresAuth: false,
      );

      print('📥 Login Response: $response');

      // ✅ Check response status or expected fields
      final statusCode =
          response['statusCode'] ?? 201; // fallback if not wrapped
      if ((statusCode == 200 || statusCode == 201) &&
          response.containsKey('user') &&
          response.containsKey('accessToken')) {
        final userJson = Map<String, dynamic>.from(response['user']);
        final token = response['accessToken'];
        final refreshToken = response['refreshToken'];

        print('✅ Token: $token');

        // ✅ Fix profile photo URL if needed
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
        await storage.write(key: 'refresh_token', value: refreshToken ?? '');
        await storage.write(key: 'user_id', value: user.id?.toString() ?? '');
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
      print('📦 Sending OTP request with body: {"phone": "$phone"}');

      final response = await _apiService.post(
        ApiConfig.otpSendEndpoint,
        body: {'phone': phone},
        requiresAuth: false,
      );

      print('📥 Response Status: ${response['statusCode'] ?? 'unknown'}');
      print('📥 Response Body: $response');

      // ✅ Check for success by status or status field
      final apiStatus = response['status'];
      final statusCode = response['statusCode'] ?? 201;
      final code = response['code'];

      if ((statusCode == 200 || statusCode == 201) &&
          (apiStatus == 'success' || code == 200)) {
        final otpData = response['data']?['otpDetails'];
        print('✅ OTP sent successfully to ${otpData?['phone']}');
        print('📨 Message: ${otpData?['message']}');
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
    try {
      print('📦 Verifying OTP for $phone');

      final response = await _apiService.post(
        ApiConfig.otpVerifyEndpoint,
        body: {'phone': phone, 'otp': otp},
        requiresAuth: false,
      );

      print('📥 Response Status: ${response['statusCode'] ?? 'unknown'}');
      print('📥 Response Body: $response');

      final apiStatus = response['status'];
      final statusCode = response['statusCode'] ?? 200;
      final code = response['code'];

      if ((statusCode == 200 || statusCode == 201) &&
          (apiStatus == 'success' || code == 200)) {
        final data = response['data'] ?? response;

        // ✅ Extract token and user if present
        final token = data['token'] ?? data['accessToken'];
        final userJson = data['user'] ?? data['userDetails'] ?? {};

        if (token != null && token.toString().isNotEmpty) {
          await storage.write(key: 'auth_token', value: token.toString());
          print('🔐 auth_token saved');
        }

        if (userJson.isNotEmpty) {
          final Map<String, dynamic> uj = Map<String, dynamic>.from(userJson);
          if (uj['id'] != null) {
            await storage.write(key: 'user_id', value: uj['id'].toString());
          }
          await storage.write(key: 'user_data', value: jsonEncode(uj));
          print('👤 user_data saved');
        }

        print('✅ OTP verified successfully');
        return data;
      } else {
        throw ApiException(
          response['message'] ?? 'Invalid OTP. Please try again.',
        );
      }
    } catch (e) {
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
    try {
      print(
        '📦 Sending OTP request with body: {"phone": "$phone", "countryCode": "$countryCode"}',
      );

      final response = await _apiService.post(
        ApiConfig.otpSendEndpoint,
        body: {'phone': phone},
        requiresAuth: false,
      );

      print('📥 Response Body: $response');

      final apiStatus = response['status']?.toString().toLowerCase();
      final code = response['code'] ?? 0;

      if (apiStatus == 'success' || code == 200 || code == 201) {
        final otpData = response['data']?['otpDetails'];
        print('✅ OTP sent successfully to ${otpData?['phone'] ?? phone}');
        print('📨 Message: ${otpData?['message'] ?? 'No message received'}');

        return {
          'success': true,
          'message': otpData?['message'] ?? 'OTP sent successfully',
          'data': otpData,
        };
      } else {
        final errorMessage = response['message'] ?? 'Failed to send OTP';
        print('⚠️ OTP send failed: $errorMessage');
        return {'success': false, 'message': errorMessage, 'data': null};
      }
    } catch (e) {
      print('❌ OTP send error: $e');
      return {'success': false, 'message': e.toString(), 'data': null};
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
          : {'mobile': input.trim(), 'countryCode': '+91', 'otp': otp.trim()};

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
        key: 'user_data',
        value: jsonEncode(_currentUser!.toJson()),
      );

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
        throw Exception(
          'Missing authentication credentials. Please login again.',
        );
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
        request.files.add(
          await http.MultipartFile.fromPath('profilePhoto', profilePhoto.path),
        );
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
