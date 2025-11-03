import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../data/models/login_response.dart';
import '../data/models/register_response.dart';
import '../data/models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ==================== INITIALIZE ====================
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
      print('✅ Auto logged in as: ${_currentUser?.name}');
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
      );

      print('📥 Login Response: $response');

      if (response['success'] == true && response['data'] != null) {
        final userJson = Map<String, dynamic>.from(response['data']);

        // Fix relative image
        if (userJson['profilePhoto'] != null &&
            userJson['profilePhoto'].toString().isNotEmpty &&
            !userJson['profilePhoto'].toString().startsWith('http')) {
          userJson['profilePhoto'] =
              'https://backend.zenzio.in${userJson['profilePhoto']}';
        }

        final user = User.fromJson(userJson);
        _currentUser = user;

        // ✅ Save user ID as local session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id ?? '');
        await prefs.setString('user_data', jsonEncode(user.toJson()));

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
      );

      final registerResponse = RegisterResponse.fromJson(response);
      _currentUser = registerResponse.user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));

      return registerResponse;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== GET USER PROFILE ====================
  Future<User> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      final response = await _apiService.get(
        '${ApiConfig.userProfileEndpoint}/$userId',
        requiresAuth: false, // 👈 ADDED THIS
      );

      _currentUser = User.fromJson(response['data'] ?? response);
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));

      return _currentUser!;
    } catch (e) {
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
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final fields = {'name': name, 'email': email};

      if (password != null && password.isNotEmpty)
        fields['password'] = password;
      if (birthday != null) fields['birthday'] = birthday;
      if (anniversary != null) fields['anniversary'] = anniversary;

      final files = <String, File>{};
      if (profilePhoto != null) files['profilePhoto'] = profilePhoto;

      final response = await _apiService.multipartRequest(
        '/api/users/$userId',
        method: 'PUT',
        fields: fields,
        files: files,
        requiresAuth: false, 
      );

      print('📥 Update Response: $response');

      final userJson = (response is Map && response.containsKey('user'))
    ? response['user']
    : (response is Map && response.containsKey('data'))
        ? response['data']
        : response;


      if (userJson == null || userJson.isEmpty) {
        throw Exception('Invalid user data received from server');
      }

      final updatedUser = User.fromJson(Map<String, dynamic>.from(userJson));

      await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));
      _currentUser = updatedUser;

      print('✅ Profile updated successfully (saved locally)');
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('user_id');
    _currentUser = null;
    print('🚪 Logged out successfully');
  }

  Future<void> sendOTP({
    required String phone,
    required String countryCode,
  }) async {}

  // Future<void> updateProfileWithImage({required String name, required String email, String? password, String? birthday, String? anniversary, File? profilePhoto}) async {}
}
