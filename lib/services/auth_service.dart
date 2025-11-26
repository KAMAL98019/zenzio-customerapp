import 'dart:convert';
import 'dart:io';
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

  bool _isRefreshing = false;

  // ==================== INITIALIZE ====================
  Future<void> initialize() async {
    try {
      final userData = await storage.read(key: 'user_data');
      if (userData != null && userData.isNotEmpty) {
        _currentUser = User.fromJson(jsonDecode(userData));
        print('✅ Auto logged in as: ${_currentUser?.name}');
      } else {
        print('⚠️ No user data found in SecureStorage');
      }
    } catch (e) {
      print('❌ Initialization error: $e');
      _currentUser = null;
    }
  }

  // ==================== EMAIL VALIDATION ====================
  bool _isEmail(String input) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(input);
  }

  // ==================== TOKEN VALIDATION ====================
  Future<bool> hasValidToken() async {
    final token = await storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  // ==================== GET TOKENS ====================
  Future<String?> getAccessToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refresh_token');
  }

  // ==================== REFRESH TOKEN ====================
  Future<bool> refreshToken() async {
    // Prevent multiple concurrent refresh attempts
    if (_isRefreshing) {
      print("⏳ Token refresh already in progress, waiting...");
      await Future.delayed(const Duration(milliseconds: 500));
      return await hasValidToken();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await storage.read(key: "refresh_token");

      if (refreshToken == null || refreshToken.isEmpty) {
        print("❌ Refresh token missing");
        _isRefreshing = false;
        return false;
      }

      final url = Uri.parse(
        "${ApiConfig.baseUrl}/api/users/refresh-auth?refreshToken=$refreshToken",
      );

      print("🔄 Attempting token refresh...");
      print("🌐 URL: $url");

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'ngrok-skip-browser-warning': 'true',
              'platform': ApiService.getPlatform(),
              'User-Agent': ApiService.getPlatform(),
              'mode': 'development',
              'clientId': ApiConfig.clientId,
            },
          )
          .timeout(const Duration(seconds: 60));

      print("📥 Refresh Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final newAccessToken = data["accessToken"] ?? data["access_token"];
        final newRefreshToken = data["refreshToken"] ?? data["refresh_token"];

        if (newAccessToken == null || newAccessToken.isEmpty) {
          print("❌ No access token in refresh response");
          _isRefreshing = false;
          return false;
        }

        // Save new tokens
        await storage.write(key: "auth_token", value: newAccessToken);

        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await storage.write(key: "refresh_token", value: newRefreshToken);
        }

        print("✅ Token refreshed successfully");
        _isRefreshing = false;
        return true;
      }

      print("❌ Refresh failed with status: ${response.statusCode}");
      print("📄 Response body: ${response.body}");

      _isRefreshing = false;
      return false;
    } catch (e) {
      print("❌ Token refresh error: $e");
      _isRefreshing = false;
      return false;
    }
  }

  // ==================== EXTRACT USER DATA (HANDLES BOTH FORMATS) ====================
  Map<String, dynamic> _extractUserData(Map<String, dynamic> response) {
    Map<String, dynamic>? userJson;

    // Format 1: Registration response with fullUser
    if (response.containsKey('fullUser')) {
      userJson = Map<String, dynamic>.from(response['fullUser']);

      // Extract email from contact if not in main user object
      if (userJson['contact'] != null) {
        final contact = userJson['contact'] as Map<String, dynamic>;
        userJson['email'] = contact['encryptedEmail'];
        userJson['phone'] = contact['encryptedPhone'];
      }

      // Extract address details if needed
      if (userJson['address'] != null) {
        final address = userJson['address'] as Map<String, dynamic>;
        userJson['city'] = address['city'];
        userJson['state'] = address['state'];
        userJson['pincode'] = address['pincode'];
      }
    }
    // Format 2: Login response with user
    else if (response.containsKey('user')) {
      userJson = Map<String, dynamic>.from(response['user']);
    }
    // Format 3: Direct data
    else if (response.containsKey('data')) {
      userJson = Map<String, dynamic>.from(response['data']);
    }
    // Format 4: Response itself is the user data
    else {
      userJson = response;
    }

    if (userJson == null || userJson.isEmpty) {
      throw Exception('No user data found in response');
    }

    // Construct name if missing
    if (!userJson.containsKey('name') || userJson['name'] == null) {
      final firstName = userJson['firstName'] ?? userJson['first_name'] ?? '';
      final lastName = userJson['lastName'] ?? userJson['last_name'] ?? '';

      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        userJson['name'] = '$firstName $lastName'.trim();
      } else if (userJson['email'] != null) {
        userJson['name'] = userJson['email'].split('@')[0];
      } else {
        userJson['name'] = 'User';
      }
    }
    return userJson;
  }

  // // ==================== REGISTER ====================
  // Future<RegisterResponse> register({
  //   required String email,
  //   required String password,
  //   required String name,
  //   required String lastName,
  //   String? phone,
  //   required String countryCode,
  //   String? dateOfBirth,
  //   String? gender,
  // }) async {
  //   try {
  //     final nameParts = name.trim().split(' ');
  //     final firstName = nameParts.first;

  //     final body = {
  //       'firstName': firstName,
  //       'lastName': lastName,
  //       'photo': '',
  //       'age': '',
  //       'email': email,
  //       'phoneNumber': phone ?? '',
  //       'password': password,
  //       'bank_details': {
  //         'bank_name': '',
  //         'ifsc_code': '',
  //         'account_number': '',
  //         'account_type': '',
  //       },
  //       'address': {
  //         'city': '',
  //         'state': '',
  //         'pincode': '',
  //         'address': '',
  //         'address_secondary': '',
  //       },
  //     };

  //     print('📤 Sending registration request');

  //     final response = await _apiService.post(
  //       ApiConfig.signupEndpoint,
  //       body: body,
  //       requiresAuth: false,
  //     );

  //     print('📥 Registration Response: $response');

  //     // Extract user data using unified method
  //     final userJson = _extractUserData(response);
  //     _currentUser = User.fromJson(userJson);

  //     // Extract and save tokens
  //     final token = response['accessToken'] ??
  //         response['token'] ??
  //         response['data']?['token'];

  //     final refreshToken = response['refreshToken'] ??
  //         response['refresh_token'] ??
  //         response['data']?['refreshToken'];

  //     if (token != null && token.toString().isNotEmpty) {
  //       await storage.write(key: 'auth_token', value: token.toString());
  //       print('🔐 Access token saved');
  //     }

  //     if (refreshToken != null && refreshToken.toString().isNotEmpty) {
  //       await storage.write(key: 'refresh_token', value: refreshToken.toString());
  //       print('🔐 Refresh token saved');
  //     }

  //     // Save user data
  //     await storage.write(
  //       key: 'user_data',
  //       value: jsonEncode(_currentUser!.toJson()),
  //     );

  //     if (_currentUser!.id != null) {
  //       await storage.write(key: 'user_id', value: _currentUser!.id.toString());
  //     }

  //     // Send verification email
  //     await sendEmailVerification(email);

  //     print('✅ Registration successful: ${_currentUser!.name}');

  //     return RegisterResponse(
  //       user: _currentUser!,
  //       message: 'Registration successful',
  //     );
  //   } catch (e) {
  //     print('❌ Registration error: $e');
  //     rethrow;
  //   }
  // }

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
      final cleanFirstName = name.trim();
      final cleanLastName = lastName.trim();
      final cleanEmail = email.trim().toLowerCase();
      final cleanPhone = phone?.trim() ?? '';
      final cleanPassword = password.trim();

      if (cleanFirstName.isEmpty) {
        throw ApiException('First name is required');
      }
      if (cleanLastName.isEmpty) {
        throw ApiException('Last name is required');
      }
      if (cleanEmail.isEmpty) {
        throw ApiException('Email is required');
      }
      if (cleanPhone.isEmpty) {
        throw ApiException('Phone number is required');
      }
      if (cleanPassword.isEmpty) {
        throw ApiException('Password is required');
      }

      final body = {
        'firstName': cleanFirstName,
        'lastName': cleanLastName,
        'email': cleanEmail,
        'password': cleanPassword,
        'phoneNumber': cleanPhone,
        'photo': '',
        'age': '',
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

      print('📤 Sending registration request');
      print('📋 Request body:');
      print('   firstName: $cleanFirstName');
      print('   lastName: $cleanLastName');
      print('   email: $cleanEmail');
      print('   phone: $cleanPhone');
      print('   password length: ${cleanPassword.length}');

      final response = await _apiService.post(
        ApiConfig.signupEndpoint,
        body: body,
        requiresAuth: false,
      );

      print('📥 Registration Response received');
      print('📥 Response keys: ${response.keys.toList()}');

      // Check if response indicates success
      final statusCode = response['statusCode'] ?? response['status'] ?? 200;
      final code = response['code'];

      if (statusCode >= 400 || code == 400 || code == 422) {
        // Extract detailed error message
        String errorMsg = 'Registration failed';

        if (response['message'] != null) {
          errorMsg = response['message'].toString();
        }

        if (response['details'] != null) {
          if (response['details'] is List) {
            errorMsg = (response['details'] as List).join(', ');
          } else {
            errorMsg = response['details'].toString();
          }
        }

        if (response['data'] != null && response['data']['message'] != null) {
          errorMsg = response['data']['message'].toString();
        }

        print('❌ Registration failed: $errorMsg');
        throw ApiException(errorMsg);
      }

      final userJson = _extractUserData(response);
      _currentUser = User.fromJson(userJson);

      final token =
          response['accessToken'] ??
          response['token'] ??
          response['data']?['token'];

      final refreshToken =
          response['refreshToken'] ??
          response['refresh_token'] ??
          response['data']?['refreshToken'];

      if (token != null && token.toString().isNotEmpty) {
        await storage.write(key: 'auth_token', value: token.toString());
        print('🔐 Access token saved');
      } else {
        print('⚠️ No access token received');
      }

      if (refreshToken != null && refreshToken.toString().isNotEmpty) {
        await storage.write(
          key: 'refresh_token',
          value: refreshToken.toString(),
        );
        print('🔐 Refresh token saved');
      }

      // Save user data
      await storage.write(
        key: 'user_data',
        value: jsonEncode(_currentUser!.toJson()),
      );

      if (_currentUser!.id != null) {
        await storage.write(key: 'user_id', value: _currentUser!.id.toString());
      }

      // Send verification email
      try {
        await sendEmailVerification(cleanEmail);
      } catch (e) {
        print('⚠️ Failed to send verification email: $e');
        // Don't fail registration if email verification fails
      }

      print('✅ Registration successful: ${_currentUser!.name}');

      return RegisterResponse(
        user: _currentUser!,
        message: 'Registration successful',
      );
    } catch (e) {
      print('❌ Registration error: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // // ==================== SEND EMAIL VERIFICATION ====================
  // // This is automatically called after registration
  // Future<void> sendEmailVerification(String email) async {
  //   try {
  //     final response = await _apiService.post(
  //       ApiConfig.firebaseSendVerificationEndpoint,
  //       body: {
  //         "email": email,
  //         "redirectUrl": "https://zenzio-39b9d.firebaseapp.com/__/auth/action"
  //       },
  //       requiresAuth: true, // User must be authenticated to send verification
  //     );

  //     print('📩 Verification response: $response');

  //     if (response['statusCode'] == 200 ||
  //         response['statusCode'] == 201 ||
  //         response['status'] == 200 ||
  //         response['status'] == 201 ||
  //         response['success'] == true) {
  //       print('📩 Verification email sent successfully to $email');
  //     } else {
  //       print('⚠️ Failed to send verification: ${response['message']}');
  //       // Don't throw - verification email failure shouldn't block registration
  //     }
  //   } catch (e) {
  //     print('❌ Error sending verification email: $e');
  //     // Don't throw - verification email is not critical for registration completion
  //   }
  // }

  // ==================== SEND EMAIL VERIFICATION ====================
  Future<void> sendEmailVerification(String email) async {
    try {
      final response = await _apiService.post(
        ApiConfig.firebaseSendVerificationEndpoint,
        body: {
          "email": email,
          "redirectUrl": "https://zenzio-39b9d.firebaseapp.com/__/auth/action",
        },
        requiresAuth: true,
      );

      print('📩 Verification response: $response');

      // ✅ FIXED: Check for the correct response format
      // Backend returns: {"message":"Verification link generated successfully","link":"..."}
      if (response['message']?.toString().contains('successfully') == true ||
          response['statusCode'] == 200 ||
          response['statusCode'] == 201 ||
          response['link'] != null) {
        print('📩 Verification email sent successfully to $email');
      } else {
        print('⚠️ Failed to send verification: ${response['message']}');
        // Don't throw - verification email failure shouldn't block registration
      }
    } catch (e) {
      print('❌ Error sending verification email: $e');
      // Don't throw - verification email is not critical for registration completion
    }
  }

  // ==================== CHECK EMAIL VERIFICATION STATUS ====================
  Future<bool> checkEmailVerificationStatus(String email) async {
    try {
      final response = await _apiService.get(
        "/firebase/check-verification?email=$email",
        requiresAuth: true,
      );

      print('📧 Check verification response: $response');

      return response['verified'] == true ||
          response['isVerified'] == true ||
          response['emailVerified'] == true;
    } catch (e) {
      print('❌ Error checking verification status: $e');
      return false;
    }
  }

  // ==================== RESEND EMAIL VERIFICATION ====================
  Future<bool> resendEmailVerification(String email) async {
    try {
      final response = await _apiService.post(
        ApiConfig.firebaseSendVerificationEndpoint,
        body: {
          "email": email,
          "redirectUrl": "https://zenzio-39b9d.firebaseapp.com/__/auth/action",
        },
        requiresAuth: true,
      );

      if (response['statusCode'] == 200 ||
          response['statusCode'] == 201 ||
          response['status'] == 200 ||
          response['status'] == 201 ||
          response['success'] == true) {
        print('📩 Verification email resent successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error resending verification email: $e');
      return false;
    }
  }
  // ==================== SEND EMAIL VERIFICATION ====================
  // Future<void> sendEmailVerification(String email) async {
  //   try {
  //     final response = await _apiService.post(
  //       ApiConfig.firebaseSendVerificationEndpoint,
  //       body: {
  //         "email": email,
  //         "redirectUrl": "https://zenzio-39b9d.firebaseapp.com/__/auth/action"
  //       },
  //       requiresAuth: false, // ❗ FIXED (should NOT require auth)
  //     );

  //     print('📩 Verification response: $response');

  //     if (response['status'] == 200 || response['status'] == 201 || response['success'] == true) {
  //       print('📩 Verification email sent successfully');
  //     } else {
  //       print('⚠️ Failed to send verification: ${response['message']}');
  //     }
  //   } catch (e) {
  //     print('❌ Error sending verification email: $e');
  //   }
  // }

  // ==================== LOGIN ====================
  Future<LoginResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final body = {'email': email, 'password': password};

      print('📤 Sending login request');

      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        body: body,
        requiresAuth: false,
      );

      print('📥 Login Response received');
      print('📥 Response keys: ${response.keys.toList()}');

      final statusCode = response['statusCode'] ?? response['status'] ?? 200;

      // Check for successful login
      if ((statusCode >= 200 && statusCode < 300) ||
          response.containsKey('user') ||
          response.containsKey('fullUser')) {
        // Extract user data using unified method
        final userJson = _extractUserData(response);
        final user = User.fromJson(userJson);

        // Extract tokens
        final token =
            response['accessToken'] ??
            response['access_token'] ??
            response['token'] ??
            response['data']?['accessToken'];

        final refreshToken =
            response['refreshToken'] ??
            response['refresh_token'] ??
            response['data']?['refreshToken'];

        print('✅ User data extracted: ${user.name}');
        print('✅ Access Token: ${token != null ? "Yes" : "No"}');
        print('✅ Refresh Token: ${refreshToken != null ? "Yes" : "No"}');

        _currentUser = user;

        // Save tokens
        if (token != null && token.toString().isNotEmpty) {
          await storage.write(key: 'auth_token', value: token.toString());
          print('🔐 Access token saved');
        } else {
          throw ApiException('No access token received');
        }

        if (refreshToken != null && refreshToken.toString().isNotEmpty) {
          await storage.write(
            key: 'refresh_token',
            value: refreshToken.toString(),
          );
          print('🔐 Refresh token saved');
        }

        // Save user data
        if (user.id != null) {
          await storage.write(key: 'user_id', value: user.id.toString());
        }

        await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));

        await Future.delayed(const Duration(milliseconds: 100));

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

  // ==================== LOGIN WITH MOBILE OTP ====================
// This method directly logs in using phone and OTP
// ✅ COMPLETE FIX for loginWithOTP method
Future<LoginResponse> loginWithOTP({
  required String phone,
  required String otp,
  String countryCode = '+91',  // Default to +91 for India
}) async {
  try {
    // Ensure phone has country code
    final fullPhone = phone.startsWith('+') ? phone : '$countryCode$phone';
    
    print('📦 Logging in with OTP for: $fullPhone');

    final body = {
      'phone': fullPhone,  // ✅ Sending with country code
      'otp': otp,
    };

    final response = await _apiService.post(
      ApiConfig.loginWithOtpEndpoint,
      body: body,
      requiresAuth: false,
    );

    print('📥 OTP Login Response: $response');
    print('📥 Response keys: ${response.keys.toList()}');

    final statusCode = response['statusCode'] ?? response['status'] ?? 200;
    final code = response['code'];

    // Check for errors
    if (statusCode >= 400 || (code != null && code >= 400)) {
      String errorMsg = response['message'] ?? 
                       response['error'] ?? 
                       'OTP login failed';
      throw ApiException(errorMsg);
    }

    // Extract tokens FIRST
    final token = response['accessToken'] ?? 
                 response['access_token'] ??
                 response['token'] ??
                 response['data']?['accessToken'];
    
    final refreshToken = response['refreshToken'] ?? 
                        response['refresh_token'] ??
                        response['data']?['refreshToken'];

    if (token == null || token.toString().isEmpty) {
      throw ApiException('No access token received from server');
    }

    print('✅ Access Token: ${token.toString().substring(0, 20)}...');
    print('✅ Refresh Token: ${refreshToken != null ? "Yes" : "No"}');

    // Save tokens immediately
    await storage.write(key: 'auth_token', value: token.toString());
    print('🔐 Access token saved');

    if (refreshToken != null && refreshToken.toString().isNotEmpty) {
      await storage.write(key: 'refresh_token', value: refreshToken.toString());
      print('🔐 Refresh token saved');
    }

    // Extract user data
    Map<String, dynamic> userJson;
    
    if (response['data'] != null) {
      final data = response['data'];
      if (data is Map && data.containsKey('user')) {
        userJson = _extractUserData({'user': data['user']});
      } else if (data is Map && data.containsKey('fullUser')) {
        userJson = _extractUserData({'fullUser': data['fullUser']});
      } else {
        userJson = _extractUserData(data);
      }
    } else if (response.containsKey('user')) {
      userJson = _extractUserData(response);
    } else if (response.containsKey('fullUser')) {
      userJson = _extractUserData(response);
    } else {
      // Fallback: create minimal user with phone
      userJson = {
        'phone': fullPhone,  // Use fullPhone here too
        'name': phone,
        'email': '',
      };
      print('⚠️ No user data in response, using fallback');
    }

    final user = User.fromJson(userJson);
    _currentUser = user;

    // Save user data
    await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
    
    if (user.id != null) {
      await storage.write(key: 'user_id', value: user.id.toString());
    }
    
    await Future.delayed(const Duration(milliseconds: 100));

    print('✅ OTP Login successful: ${user.name ?? "User"}');
    
    return LoginResponse(user: user, message: 'Login successful');
  } on ApiException {
    rethrow;
  } catch (e) {
    print('❌ OTP Login error: $e');
    throw ApiException('Login failed: ${e.toString()}');
  }
}

  // ==================== SEND OTP ====================
 Future<void> sendOTP({
  required String phone,
  required String countryCode,
}) async {
  try {
    // Ensure phone has country code
    final fullPhone = phone.startsWith('+') ? phone : '$countryCode$phone';
    
    print('📦 Sending OTP to: $fullPhone');

    final response = await _apiService.post(
      ApiConfig.otpSendEndpoint,
      body: {'phone': fullPhone},  // ✅ Send with country code
      requiresAuth: false,
    );

    print('📥 OTP Response: $response');

    final apiStatus = response['status'];
    final statusCode = response['statusCode'] ?? 201;
    final code = response['code'];

    if ((statusCode == 200 || statusCode == 201) &&
        (apiStatus == 'success' || code == 200)) {
      final otpData = response['data']?['otpDetails'];
      print('✅ OTP sent to ${otpData?['phone'] ?? fullPhone}');
    } else {
      throw Exception(response['message'] ?? 'Failed to send OTP');
    }
  } catch (e) {
    print('❌ OTP send error: $e');
    rethrow;
  }
}
  // ==================== VERIFY OTP ====================
  // Future<Map<String, dynamic>> verifyOTP({
  //   required String phone,
  //   required String countryCode,
  //   required String otp,
  // }) async {
  //   try {
  //     print('📦 Verifying OTP for $phone');

  //     final response = await _apiService.post(
  //       ApiConfig.otpVerifyEndpoint,
  //       body: {'phone': phone, 'otp': otp},
  //       requiresAuth: false,
  //     );

  //     print('📥 OTP Verification Response: $response');

  //     final int code = response['code'] ?? 0;

  //     if (code != 200) {
  //       throw ApiException('Invalid OTP. Please try again.');
  //     }

  //     final data = response['data'] ?? {};

  //     // Extract and save tokens
  //     final token = response['token'];
  //     if (token != null && token.toString().isNotEmpty) {
  //       await storage.write(key: 'auth_token', value: token.toString());
  //       print('🔐 Auth token saved from OTP');
  //     }

  //     final refreshToken = response['refreshToken'];
  //     if (refreshToken != null && refreshToken.toString().isNotEmpty) {
  //       await storage.write(
  //         key: 'refresh_token',
  //         value: refreshToken.toString(),
  //       );
  //       print('🔐 Refresh token saved from OTP');
  //     }

  //     // Extract and save user using unified method
  //     if (data.isNotEmpty) {
  //       final userJson = _extractUserData(data);
  //       final user = User.fromJson(userJson);
  //       _currentUser = user;

  //       await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));

  //       if (user.id != null) {
  //         await storage.write(key: 'user_id', value: user.id.toString());
  //       }

  //       print('👤 User logged in via OTP: ${user.name}');
  //     }

  //     print('✅ OTP verified successfully');
  //     return data;
  //   } catch (e) {
  //     print('❌ OTP verification error: $e');
  //     throw ApiException('Unable to verify OTP. Please try again.');
  //   }
  // }
Future<Map<String, dynamic>> verifyOTP({
  required String phone,
  required String countryCode,
  required String otp,
}) async {
  try {
    // Ensure phone has country code
    final fullPhone = phone.startsWith('+') ? phone : '$countryCode$phone';
    
    print('📦 Verifying OTP for registration: $fullPhone');

    final response = await _apiService.post(
      ApiConfig.otpVerifyEndpoint,
      body: {'phone': fullPhone, 'otp': otp},  // ✅ Send with country code
      requiresAuth: false,
    );

    print('📥 OTP Verification Response: $response');

    final int code = response['code'] ?? 0;

    if (code != 200) {
      throw ApiException('Invalid OTP. Please try again.');
    }

    return response['data'] ?? {};
  } catch (e) {
    print('❌ OTP verification error: $e');
    throw ApiException('Unable to verify OTP. Please try again.');
  }
}
  // ==================== RESEND OTP ====================
 Future<Map<String, dynamic>> resendOTP({
  required String phone,
  required String countryCode,
}) async {
  try {
    // ✅ ADD THIS LINE - Combine country code with phone
    final fullPhone = phone.startsWith('+') ? phone : '$countryCode$phone';
    
    print('📦 Resending OTP to: $fullPhone');  // ✅ Changed to fullPhone

    final response = await _apiService.post(
      ApiConfig.otpSendEndpoint,
      body: {'phone': fullPhone},  // ✅ Changed from phone to fullPhone
      requiresAuth: false,
    );

    final apiStatus = response['status']?.toString().toLowerCase();
    final code = response['code'] ?? 0;

    if (apiStatus == 'success' || code == 200 || code == 201) {
      final otpData = response['data']?['otpDetails'];
      print('✅ OTP resent to ${otpData?['phone'] ?? fullPhone}');  // ✅ Changed to fullPhone

      return {
        'success': true,
        'message': otpData?['message'] ?? 'OTP sent successfully',
        'data': otpData,
      };
    } else {
      final errorMessage = response['message'] ?? 'Failed to send OTP';
      return {'success': false, 'message': errorMessage, 'data': null};
    }
  } catch (e) {
    print('❌ OTP resend error: $e');
    return {'success': false, 'message': e.toString(), 'data': null};
  }
}

Future<Map<String, dynamic>> sendForgotPasswordOTP(String emailOrPhone) async {
    try {
      final response = await _apiService.post(
        "/user/auth/request-reset-password",
        body: {
          "email": emailOrPhone,
        },
      );

      return {
        "success": true,
        "message": response["message"] ?? "Reset link sent successfully",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // ==================== FORGOT PASSWORD ====================
  // Future<Map<String, dynamic>> sendForgotPasswordOTP(String email) async {
  //   try {
  //     final trimmed = email.trim();

  //     if (trimmed.isEmpty) {
  //       return {
  //         'success': false,
  //         'message': 'Please enter your email address.',
  //       };
  //     }

  //     final body = {'emailOrMobile': trimmed};

  //     print('📤 Sending forgot password OTP');

  //     final response = await _apiService.post(
  //       ApiConfig.forgotPasswordEndpoint,
  //       body: body,
  //       requiresAuth: false,
  //     );

  //     print('📥 Forgot Password Response: $response');

  //     if (response['success'] == true) {
  //       return {
  //         'success': true,
  //         'message': response['message'] ?? 'OTP sent successfully',
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'message': response['message'] ?? 'Failed to send OTP',
  //       };
  //     }
  //   } catch (e) {
  //     print('❌ Forgot password error: $e');
  //     return {
  //       'success': false,
  //       'message': 'Something went wrong: ${e.toString()}',
  //     };
  //   }
  // }

  // ==================== VERIFY FORGOT PASSWORD OTP ====================
  Future<Map<String, dynamic>> verifyForgotPasswordOTP({
    required String input,
    required String otp,
  }) async {
    try {
      final bool isEmail = _isEmail(input.trim());

      final body = isEmail
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
      print('❌ Verify forgot password OTP error: $e');
      return {
        'success': false,
        'message': 'Something went wrong: ${e.toString()}',
      };
    }
  }

  // ==================== GET USER PROFILE ====================
  // Future<User> getUserProfile() async {
  //   try {
  //     final token = await storage.read(key: 'auth_token');
  //     final userId = await storage.read(key: 'user_id');

  //     if (token == null || userId == null) {
  //       throw Exception('Missing authentication credentials');
  //     }

  //     final response = await _apiService.get(
  // ApiConfig.userProfileEndpoint,

  //       requiresAuth: true,
  //     );

  //     final userJson = _extractUserData(response);
  //     _currentUser = User.fromJson(userJson);

  //     await storage.write(
  //       key: 'user_data',
  //       value: jsonEncode(_currentUser!.toJson()),
  //     );

  //     print('✅ User profile fetched');
  //     return _currentUser!;
  //   } catch (e) {
  //     print('❌ Error fetching user profile: $e');
  //     rethrow;
  //   }
  // }

  //  Future<User> getUserProfile() async {
  //     try {
  //       final response = await _apiService.get(
  //         ApiConfig.userProfileEndpoint, // '/users/me'
  //         requiresAuth: true,            // token is automatically included in headers
  //       );

  //       final userJson = response["data"] ?? response;

  //       return User.fromJson(userJson);
  //     } catch (e) {
  //       print('❌ Error fetching user profile: $e');
  //       rethrow;
  //     }
  //   }
  // In auth_service.dart

  // Keep your existing getUserProfile() method for backward compatibility
  Future<User> getUserProfile() async {
    try {
      final response = await _apiService.get(
        ApiConfig.userProfileEndpoint,
        requiresAuth: true,
      );

      final userJson = response["data"] ?? response;

      return User.fromJson(userJson);
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      rethrow;
    }
  }

  // Add this NEW method that returns both User and original JSON
  Future<Map<String, dynamic>> getUserProfileWithJson() async {
    try {
      final response = await _apiService.get(
        ApiConfig.userProfileEndpoint,
        requiresAuth: true,
      );

      final userJson = response["data"] ?? response;
      final user = User.fromJson(userJson);

      return {
        'user': user,
        'json': userJson, // Original JSON with nested structure
      };
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

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      if (profilePhoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profilePhoto', profilePhoto.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = _extractUserData(data);
        final updatedUser = User.fromJson(userJson);

        await storage.write(
          key: 'user_data',
          value: jsonEncode(updatedUser.toJson()),
        );

        _currentUser = updatedUser;

        print('✅ Profile updated successfully');
      } else {
        print('❌ Update failed: ${response.statusCode}');
        print('📄 Response: ${response.body}');
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      await storage.deleteAll();
      _currentUser = null;
      print('🚪 Logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }
}




// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../config/api_config.dart';
// import '../data/models/login_response.dart';
// import '../data/models/register_response.dart';
// import '../data/models/user_model.dart';
// import 'api_service.dart';

// class AuthService {
//   static final AuthService _instance = AuthService._internal();
//   factory AuthService() => _instance;
//   AuthService._internal();

//   final _apiService = ApiService();
//   final storage = const FlutterSecureStorage();

//   User? _currentUser;
//   User? get currentUser => _currentUser;
//   bool get isLoggedIn => _currentUser != null;

//   // Prevent concurrent refresh attempts
//   bool _isRefreshing = false;

//   // ==================== INITIALIZE ====================
//   Future<void> initialize() async {
//     try {
//       final userData = await storage.read(key: 'user_data');
//       if (userData != null && userData.isNotEmpty) {
//         _currentUser = User.fromJson(jsonDecode(userData));
//         print('✅ Auto logged in as: ${_currentUser?.name}');
//       } else {
//         print('⚠️ No user data found in SecureStorage');
//       }
//     } catch (e) {
//       print('❌ Initialization error: $e');
//       _currentUser = null;
//     }
//   }

//   // ==================== EMAIL VALIDATION ====================
//   bool _isEmail(String input) {
//     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     return emailRegex.hasMatch(input);
//   }

//   // ==================== TOKEN VALIDATION ====================
//   Future<bool> hasValidToken() async {
//     final token = await storage.read(key: 'auth_token');
//     return token != null && token.isNotEmpty;
//   }

//   // ==================== GET TOKENS ====================
//   Future<String?> getAccessToken() async {
//     return await storage.read(key: 'auth_token');
//   }

//   Future<String?> getRefreshToken() async {
//     return await storage.read(key: 'refresh_token');
//   }

//   // ==================== REFRESH TOKEN ====================
//   Future<bool> refreshToken() async {
//     // Prevent multiple concurrent refresh attempts
//     if (_isRefreshing) {
//       print("⏳ Token refresh already in progress, waiting...");
//       await Future.delayed(const Duration(milliseconds: 500));
//       return await hasValidToken();
//     }

//     _isRefreshing = true;

//     try {
//       final refreshToken = await storage.read(key: "refresh_token");

//       if (refreshToken == null || refreshToken.isEmpty) {
//         print("❌ Refresh token missing");
//         _isRefreshing = false;
//         return false;
//       }

//       final url = Uri.parse(
//         "${ApiConfig.baseUrl}${ApiConfig.apiVersion}${ApiConfig.refreshAuth}?refreshToken=$refreshToken",
//       );

//       print("🔄 Attempting token refresh...");
//       print("🌐 URL: $url");

//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'ngrok-skip-browser-warning': 'true',
//           'platform': ApiService.getPlatform(),
//           'User-Agent': ApiService.getPlatform(),
//           'mode': 'development',
//           'clientId': ApiConfig.clientId,
//         },
//       ).timeout(
//         const Duration(seconds: 60),
//       );

//       print("📥 Refresh Response Status: ${response.statusCode}");

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         final newAccessToken = data["accessToken"] ?? data["access_token"];
//         final newRefreshToken = data["refreshToken"] ?? data["refresh_token"];

//         if (newAccessToken == null || newAccessToken.isEmpty) {
//           print("❌ No access token in refresh response");
//           _isRefreshing = false;
//           return false;
//         }

//         // Save new tokens
//         await storage.write(key: "auth_token", value: newAccessToken);
        
//         if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
//           await storage.write(key: "refresh_token", value: newRefreshToken);
//         }

//         print("✅ Token refreshed successfully");
//         _isRefreshing = false;
//         return true;
//       }

//       print("❌ Refresh failed with status: ${response.statusCode}");
//       print("📄 Response body: ${response.body}");
      
//       _isRefreshing = false;
//       return false;
//     } catch (e) {
//       print("❌ Token refresh error: $e");
//       _isRefreshing = false;
//       return false;
//     }
//   }

//   // ==================== REGISTER ====================
//   Future<RegisterResponse> register({
//     required String email,
//     required String password,
//     required String name,
//     required String lastName,
//     String? phone,
//     required String countryCode,
//     String? dateOfBirth,
//     String? gender,
//   }) async {
//     try {
//       final nameParts = name.trim().split(' ');
//       final firstName = nameParts.first;

//       final body = {
//         'firstName': firstName,
//         'lastName': lastName,
//         'photo': '',
//         'age': '',
//         'email': email,
//         'phoneNumber': phone ?? '',
//         'password': password,
//         'bank_details': {
//           'bank_name': '',
//           'ifsc_code': '',
//           'account_number': '',
//           'account_type': '',
//         },
//         'address': {
//           'city': '',
//           'state': '',
//           'pincode': '',
//           'address': '',
//           'address_secondary': '',
//         },
//       };

//       print('📤 Sending registration request');

//       final response = await _apiService.post(
//         ApiConfig.signupEndpoint,
//         body: body,
//         requiresAuth: false,
//       );

//       print('📥 Registration Response: $response');

//       final userJson = response['fullUser'] ??
//           response['data']?['fullUser'] ??
//           response['data'] ??
//           response;

//       if (userJson == null) {
//         throw Exception('No user data returned from API');
//       }

//       _currentUser = User.fromJson(Map<String, dynamic>.from(userJson));

//       // Extract and save tokens
//       final token = response['accessToken'] ??
//           response['token'] ??
//           response['data']?['token'];

//       final refreshToken = response['refreshToken'] ??
//           response['refresh_token'] ??
//           response['data']?['refreshToken'];

//       if (token != null && token.toString().isNotEmpty) {
//         await storage.write(key: 'auth_token', value: token.toString());
//         print('🔐 Access token saved');
//       }

//       if (refreshToken != null && refreshToken.toString().isNotEmpty) {
//         await storage.write(key: 'refresh_token', value: refreshToken.toString());
//         print('🔐 Refresh token saved');
//       }

//       // Save user data
//       await storage.write(
//         key: 'user_data',
//         value: jsonEncode(_currentUser!.toJson()),
//       );

//       if (_currentUser!.id != null) {
//         await storage.write(key: 'user_id', value: _currentUser!.id.toString());
//       }

//       // Send verification email
//       await sendEmailVerification(email);

//       print('✅ Registration successful');

//       return RegisterResponse(
//         user: _currentUser!,
//         message: 'Registration successful',
//       );
//     } catch (e) {
//       print('❌ Registration error: $e');
//       rethrow;
//     }
//   }

//   // ==================== SEND EMAIL VERIFICATION ====================
//   Future<void> sendEmailVerification(String email) async {
//     try {
//       final response = await _apiService.post(
//         ApiConfig.firebaseSendVerificationEndpoint,
//         body: {
//           "email": email,
//           "redirectUrl": "https://zenzio-39b9d.firebaseapp.com/__/auth/action"
//         },
//         requiresAuth: true,
//       );

//       print('📩 Verification response: $response');

//       if (response['statusCode'] == 200 || response['statusCode'] == 201) {
//         print('📩 Verification email sent successfully');
//       } else {
//         print('⚠️ Failed to send verification: ${response['message']}');
//       }
//     } catch (e) {
//       print('❌ Error sending verification email: $e');
//       // Don't throw - verification email is not critical for login
//     }
//   }

//   // ==================== LOGIN ====================
//   Future<LoginResponse> loginWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final body = {'email': email, 'password': password};

//       print('📤 Sending login request');

//       final response = await _apiService.post(
//         ApiConfig.loginEndpoint,
//         body: body,
//         requiresAuth: false,
//       );

//       print('📥 Login Response received');
//       print('📥 Response keys: ${response.keys.toList()}');

//       final statusCode = response['statusCode'] ?? response['status'] ?? 200;
      
//       // Check for successful login
//       if ((statusCode >= 200 && statusCode < 300) || response.containsKey('user')) {
        
//         // Extract user data - handle different response structures
//         dynamic rawUserJson = response['user'] ?? 
//                               response['data']?['user'] ?? 
//                               response['data'];
        
//         if (rawUserJson == null) {
//           throw ApiException('No user data in response');
//         }
        
//         // Convert to Map if needed
//         final Map<String, dynamic> userJson;
//         if (rawUserJson is Map) {
//           userJson = Map<String, dynamic>.from(rawUserJson);
//         } else {
//           throw ApiException('Invalid user data format');
//         }
        
//         print('📦 User JSON: $userJson');
        
//         // Debug: Check what fields are present
//         print('📋 Available user fields: ${userJson.keys.toList()}');
        
//         // Try to construct name if it's missing
//         if (!userJson.containsKey('name') || userJson['name'] == null) {
//           final firstName = userJson['firstName'] ?? userJson['first_name'] ?? '';
//           final lastName = userJson['lastName'] ?? userJson['last_name'] ?? '';
          
//           if (firstName.isNotEmpty || lastName.isNotEmpty) {
//             userJson['name'] = '$firstName $lastName'.trim();
//             print('🔧 Constructed name from firstName + lastName: ${userJson['name']}');
//           } else {
//             // Use email as fallback
//             userJson['name'] = userJson['email']?.split('@')[0] ?? 'User';
//             print('⚠️  No name fields found, using email prefix: ${userJson['name']}');
//           }
//         }
        
//         final user = User.fromJson(userJson);
        
//         // Extract tokens - try multiple possible keys
//         final token = response['accessToken'] ?? 
//                      response['access_token'] ??
//                      response['token'] ??
//                      response['data']?['accessToken'] ??
//                      response['data']?['token'];
        
//         final refreshToken = response['refreshToken'] ?? 
//                             response['refresh_token'] ??
//                             response['data']?['refreshToken'];

//         print('✅ User data extracted: ${user.name}');
//         print('✅ Access Token received: ${token != null ? "Yes (${token.toString().substring(0, 20)}...)" : "No"}');
//         print('✅ Refresh Token received: ${refreshToken != null ? "Yes" : "No"}');

//         // Fix profile photo URL if needed
//         if (userJson['profilePhoto'] != null &&
//             userJson['profilePhoto'].toString().isNotEmpty &&
//             !userJson['profilePhoto'].toString().startsWith('http')) {
//           userJson['profilePhoto'] =
//               'https://backend.zenzio.in${userJson['profilePhoto']}';
//         }

//         _currentUser = user;

//         // Save tokens - CRITICAL: Do this synchronously
//         if (token != null && token.toString().isNotEmpty) {
//           await storage.write(key: 'auth_token', value: token.toString());
//           print('🔐 Access token saved successfully');
          
//           // Verify it was saved
//           final savedToken = await storage.read(key: 'auth_token');
//           print('✅ Token verification: ${savedToken != null ? "Success" : "Failed"}');
//         } else {
//           print('⚠️ No access token in response!');
//           throw ApiException('No access token received from server');
//         }

//         if (refreshToken != null && refreshToken.toString().isNotEmpty) {
//           await storage.write(key: 'refresh_token', value: refreshToken.toString());
//           print('🔐 Refresh token saved successfully');
//         }

//         // Save user data
//         if (user.id != null) {
//           await storage.write(key: 'user_id', value: user.id.toString());
//         }

//         await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
        
//         // Add small delay to ensure storage write completes
//         await Future.delayed(const Duration(milliseconds: 100));

//         print('✅ Login successful: ${user.name}');
//         print('✅ User ID: ${user.id}');
        
//         return LoginResponse(user: user, message: 'Login successful');
//       } else {
//         throw ApiException(response['message'] ?? 'Login failed');
//       }
//     } catch (e) {
//       print('❌ Login error: $e');
//       rethrow;
//     }
//   }

//   // ==================== SEND OTP ====================
//   Future<void> sendOTP({
//     required String phone,
//     required String countryCode,
//   }) async {
//     try {
//       print('📦 Sending OTP to: $phone');

//       final response = await _apiService.post(
//         ApiConfig.otpSendEndpoint,
//         body: {'phone': phone},
//         requiresAuth: false,
//       );

//       print('📥 OTP Response: $response');

//       final apiStatus = response['status'];
//       final statusCode = response['statusCode'] ?? 201;
//       final code = response['code'];

//       if ((statusCode == 200 || statusCode == 201) &&
//           (apiStatus == 'success' || code == 200)) {
//         final otpData = response['data']?['otpDetails'];
//         print('✅ OTP sent to ${otpData?['phone'] ?? phone}');
//       } else {
//         throw Exception(response['message'] ?? 'Failed to send OTP');
//       }
//     } catch (e) {
//       print('❌ OTP send error: $e');
//       rethrow;
//     }
//   }

//   // ==================== VERIFY OTP ====================
//   Future<Map<String, dynamic>> verifyOTP({
//     required String phone,
//     required String countryCode,
//     required String otp,
//   }) async {
//     try {
//       print('📦 Verifying OTP for $phone');

//       final response = await _apiService.post(
//         ApiConfig.otpVerifyEndpoint,
//         body: {'phone': phone, 'otp': otp},
//         requiresAuth: false,
//       );

//       print('📥 OTP Verification Response: $response');

//       final int code = response['code'] ?? 0;

//       if (code != 200) {
//         throw ApiException('Invalid OTP. Please try again.');
//       }

//       final data = response['data'] ?? {};

//       // Extract and save tokens
//       final token = response['token'];
//       if (token != null && token.toString().isNotEmpty) {
//         await storage.write(key: 'auth_token', value: token.toString());
//         print('🔐 Auth token saved from OTP');
//       }

//       final refreshToken = response['refreshToken'];
//       if (refreshToken != null && refreshToken.toString().isNotEmpty) {
//         await storage.write(key: 'refresh_token', value: refreshToken.toString());
//         print('🔐 Refresh token saved from OTP');
//       }

//       // Extract and save user
//       final userJson = data['user'] ?? {};
//       if (userJson.isNotEmpty) {
//         final user = User.fromJson(Map<String, dynamic>.from(userJson));
//         _currentUser = user;

//         await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
        
//         if (user.id != null) {
//           await storage.write(key: 'user_id', value: user.id.toString());
//         }

//         print('👤 User logged in via OTP: ${user.name}');
//       }

//       print('✅ OTP verified successfully');
//       return data;
//     } catch (e) {
//       print('❌ OTP verification error: $e');
//       throw ApiException('Unable to verify OTP. Please try again.');
//     }
//   }

//   // ==================== RESEND OTP ====================
//   Future<Map<String, dynamic>> resendOTP({
//     required String phone,
//     required String countryCode,
//   }) async {
//     try {
//       print('📦 Resending OTP to: $phone');

//       final response = await _apiService.post(
//         ApiConfig.otpSendEndpoint,
//         body: {'phone': phone},
//         requiresAuth: false,
//       );

//       final apiStatus = response['status']?.toString().toLowerCase();
//       final code = response['code'] ?? 0;

//       if (apiStatus == 'success' || code == 200 || code == 201) {
//         final otpData = response['data']?['otpDetails'];
//         print('✅ OTP resent to ${otpData?['phone'] ?? phone}');

//         return {
//           'success': true,
//           'message': otpData?['message'] ?? 'OTP sent successfully',
//           'data': otpData,
//         };
//       } else {
//         final errorMessage = response['message'] ?? 'Failed to send OTP';
//         return {'success': false, 'message': errorMessage, 'data': null};
//       }
//     } catch (e) {
//       print('❌ OTP resend error: $e');
//       return {'success': false, 'message': e.toString(), 'data': null};
//     }
//   }

//   // ==================== FORGOT PASSWORD ====================
//   Future<Map<String, dynamic>> sendForgotPasswordOTP(String email) async {
//     try {
//       final trimmed = email.trim();

//       if (trimmed.isEmpty) {
//         return {
//           'success': false,
//           'message': 'Please enter your email address.',
//         };
//       }

//       final body = {'emailOrMobile': trimmed};

//       print('📤 Sending forgot password OTP');

//       final response = await _apiService.post(
//         ApiConfig.forgotPasswordEndpoint,
//         body: body,
//         requiresAuth: false,
//       );

//       print('📥 Forgot Password Response: $response');

//       if (response['success'] == true) {
//         return {
//           'success': true,
//           'message': response['message'] ?? 'OTP sent successfully',
//         };
//       } else {
//         return {
//           'success': false,
//           'message': response['message'] ?? 'Failed to send OTP',
//         };
//       }
//     } catch (e) {
//       print('❌ Forgot password error: $e');
//       return {
//         'success': false,
//         'message': 'Something went wrong: ${e.toString()}',
//       };
//     }
//   }

//   // ==================== VERIFY FORGOT PASSWORD OTP ====================
//   Future<Map<String, dynamic>> verifyForgotPasswordOTP({
//     required String input,
//     required String otp,
//   }) async {
//     try {
//       final bool isEmail = _isEmail(input.trim());
      
//       final body = isEmail
//           ? {'email': input.trim(), 'otp': otp.trim()}
//           : {'mobile': input.trim(), 'countryCode': '+91', 'otp': otp.trim()};

//       final response = await _apiService.post(
//         ApiConfig.resetPasswordEndpoint,
//         body: body,
//         requiresAuth: false,
//       );

//       if (response['success'] == true) {
//         return {
//           'success': true,
//           'message': response['message'] ?? 'OTP verified successfully',
//         };
//       } else {
//         return {
//           'success': false,
//           'message': response['message'] ?? 'Invalid or expired OTP',
//         };
//       }
//     } catch (e) {
//       print('❌ Verify forgot password OTP error: $e');
//       return {
//         'success': false,
//         'message': 'Something went wrong: ${e.toString()}',
//       };
//     }
//   }

//   // ==================== GET USER PROFILE ====================
//   Future<User> getUserProfile() async {
//     try {
//       final token = await storage.read(key: 'auth_token');
//       final userId = await storage.read(key: 'user_id');

//       if (token == null || userId == null) {
//         throw Exception('Missing authentication credentials');
//       }

//       final response = await _apiService.get(
//         '${ApiConfig.userProfileEndpoint}/$userId',
//         requiresAuth: true,
//       );

//       _currentUser = User.fromJson(response['data'] ?? response);

//       await storage.write(
//         key: 'user_data',
//         value: jsonEncode(_currentUser!.toJson()),
//       );

//       print('✅ User profile fetched');
//       return _currentUser!;
//     } catch (e) {
//       print('❌ Error fetching user profile: $e');
//       rethrow;
//     }
//   }

//   // ==================== UPDATE PROFILE ====================
//   Future<void> updateProfileWithImage({
//     required String name,
//     required String email,
//     String? password,
//     String? birthday,
//     String? anniversary,
//     File? profilePhoto,
//   }) async {
//     try {
//       final token = await storage.read(key: 'auth_token');
//       final userId = await storage.read(key: 'user_id');

//       if (userId == null || token == null || token.isEmpty) {
//         throw Exception('Missing authentication credentials. Please login again.');
//       }

//       final fields = {
//         'name': name,
//         'email': email,
//         if (password != null && password.isNotEmpty) 'password': password,
//         if (birthday != null) 'birthday': birthday,
//         if (anniversary != null) 'anniversary': anniversary,
//       };

//       final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/$userId');
//       final request = http.MultipartRequest('PUT', uri);

//       request.headers['Authorization'] = 'Bearer $token';
//       request.headers['Accept'] = 'application/json';

//       fields.forEach((key, value) {
//         request.fields[key] = value;
//       });

//       if (profilePhoto != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath('profilePhoto', profilePhoto.path),
//         );
//       }

//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final userJson = data['user'] ?? data['data'] ?? data;
//         final updatedUser = User.fromJson(Map<String, dynamic>.from(userJson));

//         await storage.write(
//           key: 'user_data',
//           value: jsonEncode(updatedUser.toJson()),
//         );
        
//         _currentUser = updatedUser;

//         print('✅ Profile updated successfully');
//       } else {
//         print('❌ Update failed: ${response.statusCode}');
//         print('📄 Response: ${response.body}');
//         throw Exception('Failed to update profile: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error updating profile: $e');
//       rethrow;
//     }
//   }

//   // ==================== LOGOUT ====================
//   Future<void> logout() async {
//     try {
//       await storage.deleteAll();
//       _currentUser = null;
//       print('🚪 Logged out successfully');
//     } catch (e) {
//       print('❌ Logout error: $e');
//       rethrow;
//     }
//   }
// }
