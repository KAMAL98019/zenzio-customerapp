// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../data/models/login_request.dart';
import '../data/models/login_response.dart';
import '../data/models/register_request.dart';
import '../data/models/register_response.dart';
import '../data/models/user_model.dart';
import 'api_service.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null && _apiService.authToken != null;

  // ==================== INITIALIZE ====================
  Future<void> initialize() async {
    await _apiService.loadToken();
    
    if (_apiService.authToken != null) {
      try {
        // Load user profile if token exists
        await getUserProfile();
      } catch (e) {
        // Token might be expired, clear it
        await logout();
      }
    }
  }

  // ==================== LOGIN WITH EMAIL ====================
 Future<LoginResponse> loginWithEmail({
  required String email,
  required String password,
}) async {
  try {
    final response = await _apiService.post(
      ApiConfig.loginEndpoint, // Make sure this includes apiBaseUrl
      body: {
        'emailOrMobile': email, // ✅ Backend expects this key
        'password': password,
      },
    );

    print('📥 Full Response: $response'); // ✅ Debug log

    // ✅ Response structure:
    // { "success": true, "message": "Login successful", "data": { user info } }

    if (response['success'] == true && response['data'] != null) {
      final userJson = response['data'];
      final user = User.fromJson(userJson);

      final loginResponse = LoginResponse(
        user: user,
        message: response['message'] ?? 'Login successful',
      );

      _currentUser = user;
      await _saveUserData(user);

      return loginResponse;
    } else {
      throw ApiException(response['message'] ?? 'Login failed');
    }
  } catch (e) {
    print('❌ Login error: $e');
    rethrow;
  }
}



  // ==================== LOGIN WITH PHONE ====================
  Future<LoginResponse> loginWithPhone({
    required String phone,
    required String countryCode,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        body: {
          'phone': phone,
          'countryCode': countryCode,
          'password': password,
        },
      );

      final loginResponse = LoginResponse.fromJson(response);
      
      if (loginResponse.token != null) {
        await _apiService.saveToken(loginResponse.token!);
        _currentUser = loginResponse.user;
        await _saveUserData(loginResponse.user);
      }

      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== SEND OTP ====================
  Future<Map<String, dynamic>> sendOTP({
    required String phone,
    required String countryCode,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.otpSendEndpoint,
        body: {
          'phone': phone,
          'countryCode': countryCode,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== VERIFY OTP ====================
  Future<LoginResponse> verifyOTP({
    required String phone,
    required String countryCode,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.otpVerifyEndpoint,
        body: {
          'phone': phone,
          'countryCode': countryCode,
          'otp': otp,
        },
      );

      final loginResponse = LoginResponse.fromJson(response);
      
      if (loginResponse.token != null) {
        await _apiService.saveToken(loginResponse.token!);
        _currentUser = loginResponse.user;
        await _saveUserData(loginResponse.user);
      }

      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== REGISTER ====================
  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? countryCode,
  }) async {
    try {
      final body = {
  'name': name,
  'email': email,
  'password': password,
  'mobile': phone ?? '',
  'birthday': DateTime.now().toIso8601String(),
  'anniversary': DateTime.now().toIso8601String(),
};

      
      if (phone != null) body['phone'] = phone;
      if (countryCode != null) body['countryCode'] = countryCode;

      final response = await _apiService.post(
        ApiConfig.signupEndpoint,
        body: body,
      );

      final registerResponse = RegisterResponse.fromJson(response);
      
      // Auto-login after registration
      if (registerResponse.token != null) {
        await _apiService.saveToken(registerResponse.token!);
        _currentUser = registerResponse.user;
        await _saveUserData(registerResponse.user);
      }

      return registerResponse;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== FORGOT PASSWORD ====================
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.forgotPasswordEndpoint,
        body: {
          'email': email,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== RESET PASSWORD ====================
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.resetPasswordEndpoint,
        body: {
          'token': token,
          'password': newPassword,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== GET USER PROFILE ====================
  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get(
        ApiConfig.userProfileEndpoint,
        requiresAuth: true,
      );

      _currentUser = User.fromJson(response['data'] ?? response);
      await _saveUserData(_currentUser);
      
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== UPDATE PROFILE ====================
  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? countryCode,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (countryCode != null) body['countryCode'] = countryCode;

      final response = await _apiService.put(
        ApiConfig.updateProfileEndpoint,
        body: body,
        requiresAuth: true,
      );

      _currentUser = User.fromJson(response['data'] ?? response);
      await _saveUserData(_currentUser);
      
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      // Call logout endpoint (if your backend has one)
      await _apiService.post(
        ApiConfig.logoutEndpoint,
        body: {},
        requiresAuth: true,
      ).catchError((_) {});
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      // Clear local data
      await _apiService.clearToken();
      _currentUser = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    }
  }

  // ==================== SAVE USER DATA ====================
  Future<void> _saveUserData(User? user) async {
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson()); // ✅ proper JSON encoding
    await prefs.setString('user_data', userJson);
  }

  // ==================== LOAD USER DATA ====================
 Future<void> loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final userData = prefs.getString('user_data');

  if (userData != null) {
    try {
      final userMap = jsonDecode(userData);
      _currentUser = User.fromJson(userMap);
      print('✅ Loaded user: ${_currentUser?.name}');
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }
}
}
