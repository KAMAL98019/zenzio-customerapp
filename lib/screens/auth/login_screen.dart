import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zenzio/core/status_codes.dart';
import 'package:zenzio/screens/auth/VerifyEmailScreen.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/custom_button.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedCountryCode = '+91';
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ===================== PHONE LOGIN (OTP) =====================
 Future<void> _handlePhoneLogin() async {
  final phone = _phoneController.text.trim();

  if (phone.isEmpty) {
    _showErrorDialog('Please enter your phone number');
    return;
  }
  if (phone.length != 10) {
    _showErrorDialog('Please enter a valid 10-digit phone number');
    return;
  }
  setState(() => _isLoading = true);

  try {
    await _authService.sendOTP(
      phone: phone,
      countryCode: _selectedCountryCode,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent successfully to $_selectedCountryCode$phone'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushNamed(
      context,
      '/otp',
      arguments: {'phone': phone, 'countryCode': _selectedCountryCode},
    );
  } on ApiException catch (e) {
    if (!mounted) return;

    setState(() => _isLoading = false);

    String errorMessage = e.message;

    // Extract clean JSON part if present
    try {
      final match = RegExp(r'\{.*\}').firstMatch(e.message);
      if (match != null) {
        final Map<String, dynamic> errorJson = jsonDecode(match.group(0)!);

        if (errorJson.containsKey('message')) {
          errorMessage = errorJson['message'];
        } else if (errorJson.containsKey('details')) {
          final details = errorJson['details'];
          if (details is List) {
            errorMessage = details.join("\n");
          }
        }
      }
    } catch (_) {}

    // 🎯 Convert backend error CODE → Human readable message
    errorMessage = StatusMessages.get(errorMessage);

    _showErrorDialog(errorMessage);
  } catch (e) {
    if (!mounted) return;

    setState(() => _isLoading = false);
    _showErrorDialog('Failed to send OTP. Please try again.');
  }
}

  // ===================== EMAIL LOGIN ===================== 
// ===================== EMAIL LOGIN ===================== 
Future<void> _handleEmailLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  // ==================== VALIDATION ====================
  if (email.isEmpty || password.isEmpty) {
    _showErrorDialog('Please enter both email and password');
    return;
  }

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email)) {
    _showErrorDialog('Please enter a valid email address');
    return;
  }

  setState(() => _isLoading = true);

  try {
    final loginResponse = await _authService.loginWithEmail(
      email: email,
      password: password,
    );

    if (!mounted) return;

    // ==================== CASE 1: EMAIL NOT VERIFIED (201) ====================
    if (loginResponse.statusCode == 201 || 
        loginResponse.emailVerified == false) {
      
      setState(() => _isLoading = false);

      print('⚠️ Email not verified - redirecting to verification screen');

      // Show dialog with option to resend email
      final shouldNavigate = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Email Not Verified'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your email address has not been verified yet.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                email,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please check your inbox and click the verification link to continue.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Go to Verification',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (shouldNavigate == true && mounted) {
        // If backend didn't send email automatically, send it now
        if (loginResponse.verificationLink == null) {
          try {
            await _authService.sendEmailVerification(email);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Verification email sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('⚠️ Failed to send verification email: $e');
          }
        }

        // Navigate to verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(email: email),
          ),
        );
      }
      return;
    }

    // ==================== CASE 2: SUCCESSFUL LOGIN ====================
    if (loginResponse.user != null && loginResponse.emailVerified == true) {
      setState(() => _isLoading = false);

      print('✅ Login completed successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main-navigation',
        (route) => false,
      );
      return;
    }

    // If we reach here, something unexpected happened
    setState(() => _isLoading = false);
    _showErrorDialog('Login failed. Please try again.');

  } on ApiException catch (e) {
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    print('⚠️ API Error: ${e.message} (Status: ${e.statusCode})');

    // ==================== CASE 3: TOO MANY ATTEMPTS (429) ====================
    if (e.statusCode == 429 || 
        e.message.contains('TOO_MANY_ATTEMPTS') ||
        e.message.contains('too many attempts')) {
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Too Many Attempts'),
          content: const Text(
            'You have made too many login attempts. Please try again later.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // ==================== CASE 4: INVALID CREDENTIALS (401) ====================
    if (e.statusCode == 401) {
      _showErrorDialog('Invalid email or password. Please try again.');
      return;
    }

    // ==================== CASE 5: OTHER API ERRORS ====================
    String errorMessage = e.message;
    
    // Try to extract clean error message from JSON
    try {
      final RegExp jsonFinder = RegExp(r'\{.*\}');
      final match = jsonFinder.firstMatch(e.message);
      if (match != null) {
        final jsonString = match.group(0)!;
        final Map<String, dynamic> errorData = jsonDecode(jsonString);

        if (errorData.containsKey('details') && errorData['details'] is List) {
          errorMessage = (errorData['details'] as List).join('\n');
        } else if (errorData.containsKey('details')) {
          errorMessage = errorData['details'].toString();
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'].toString();
        }
      }
    } catch (_) {
      // If parsing fails, use original message
    }
    
    _showErrorDialog(errorMessage);

  } catch (e) {
    // ==================== CASE 6: UNEXPECTED ERRORS ====================
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    print('❌ Unexpected error: $e');
    _showErrorDialog('An unexpected error occurred. Please try again.');
  }
}
  // Future<void> _handleEmailLogin() async {
  //   final email = _emailController.text.trim();
  //   final password = _passwordController.text;

  //   if (email.isEmpty || password.isEmpty) {
  //     _showErrorDialog('Please enter both email and password');
  //     return;
  //   }

  //   // ✅ Email validation
  //   final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  //   if (!emailRegex.hasMatch(email)) {
  //     _showErrorDialog('Please enter a valid email address');
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     final loginResponse = await _authService.loginWithEmail(
  //       email: email,
  //       password: password,
  //     );

  //     print('✅ Login completed successfully');

  //     if (!mounted) return;

  //     setState(() => _isLoading = false);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Login successful!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );

  //     await Future.delayed(const Duration(milliseconds: 500));
  //     Navigator.pushNamedAndRemoveUntil(
  //       context,
  //       '/main-navigation',
  //       (route) => false,
  //     );
  //   } on ApiException catch (e) {
  //     if (!mounted) return;
      
  //     setState(() => _isLoading = false);
      
  //     print('⚠️ API Error: ${e.message}');

  //     String errorMessage = e.message;
  //     try {
  //       final RegExp jsonFinder = RegExp(r'\{.*\}');
  //       final match = jsonFinder.firstMatch(e.message);
  //       if (match != null) {
  //         final jsonString = match.group(0)!;
  //         final Map<String, dynamic> errorData = jsonDecode(jsonString);

  //         if (errorData.containsKey('details') &&
  //             errorData['details'] is List) {
  //           errorMessage = (errorData['details'] as List).join('\n');
  //         } else if (errorData.containsKey('details')) {
  //           errorMessage = errorData['details'].toString();
  //         } else if (errorData.containsKey('message')) {
  //           errorMessage = errorData['message'].toString();
  //         }
  //       }
  //     } catch (_) {
  //       // If parsing fails, use original message
  //     }
  //     _showErrorDialog(errorMessage);
  //   } catch (e) {
  //     if (!mounted) return;
      
  //     setState(() => _isLoading = false);
  //     print('❌ Unexpected error: $e');
  //     _showErrorDialog('An unexpected error occurred. Please try again.');
  //   }
  // }

  // ===================== UI HELPERS =====================
  void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Error',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
  // void _showErrorDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Error'),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ===================== MAIN UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/images/zenzioicon.png',
                    height: 90,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text(
                          'Zenzio',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.secondary,
                      unselectedLabelColor: AppColors.textLight,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Phone Number (OTP)'),
                        Tab(text: 'Email & Password'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 360,
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildPhoneLoginTab(), _buildEmailLoginTab()],
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===================== PHONE LOGIN TAB =====================
  Widget _buildPhoneLoginTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 80,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  underline: const SizedBox(),
                  items: ['+1', '+91', '+44', '+61']
                      .map(
                        (code) => DropdownMenuItem(
                          value: code,
                          child: Text(
                            code,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCountryCode = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: _inputDecoration('Enter 10-digit mobile number'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: 'Continue',
          onPressed: _handlePhoneLogin,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        _buildSignUpText(),
      ],
    );
  }

  // ===================== EMAIL LOGIN TAB =====================
  Widget _buildEmailLoginTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
          decoration: _inputDecoration('Enter your registered email'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          enabled: !_isLoading,
          decoration: _inputDecoration('Enter your password').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9E9E9E),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        CustomButton(
          text: 'Login',
          onPressed: _handleEmailLogin,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        _buildSignUpText(),
      ],
    );
  }

  // ===================== COMMON INPUT FIELD STYLE =====================
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      counterText: '', // ✅ Hide counter text
    );
  }

  // ===================== SIGNUP TEXT =====================
  Widget _buildSignUpText() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: const TextStyle(color: AppColors.textLight, fontSize: 14),
          children: [
            TextSpan(
              text: 'Sign up',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, '/signup');
                },
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import '../../widgets/custom_button.dart';
// import '../../core/constants/app_colors.dart';
// import '../../services/auth_service.dart';
// import '../../services/api_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   String _selectedCountryCode = '+91';
//   bool _isLoading = false;

//   final AuthService _authService = AuthService();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // ===================== PHONE LOGIN (OTP) =====================
//   Future<void> _handlePhoneLogin() async {
//     final phone = _phoneController.text.trim();

//     if (phone.isEmpty) {
//       _showErrorDialog('Please enter your phone number');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       await _authService.sendOTP(
//         phone: phone,
//         countryCode: _selectedCountryCode,
//       );

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('OTP sent successfully to $_selectedCountryCode$phone'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Navigate to OTP verification page
//       Navigator.pushNamed(
//         context,
//         '/otp',
//         arguments: {'phone': phone, 'countryCode': _selectedCountryCode},
//       );
//     } on ApiException catch (e) {
//       // ✅ Extract and show details from the error
//       String errorMessage = 'Something went wrong';

//       // If error contains details array, show those instead
//       if (errorMessage.contains('details')) {
//         try {
//           final regex = RegExp(r'"details":\[(.*?)\]');
//           final match = regex.firstMatch(errorMessage);
//           if (match != null) {
//             String details = match.group(1) ?? '';
//             details = details.replaceAll('"', '').replaceAll(',', '\n• ');
//             errorMessage = '• $details';
//           }
//         } catch (_) {}
//       }

//       _showErrorDialog(errorMessage);
//     } catch (e) {
//       _showErrorDialog('Failed to send OTP. Please try again.');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ===================== EMAIL LOGIN =====================
//   Future<void> _handleEmailLogin() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     if (email.isEmpty || password.isEmpty) {
//       _showErrorDialog('Please enter both email and password');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final loginResponse = await _authService.loginWithEmail(
//         email: email,
//         password: password,
//       );

//       print('✅ Login completed successfully');

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Login successful!'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       await Future.delayed(const Duration(milliseconds: 500));

//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         '/main-navigation',
//         (route) => false,
//       );
//     } on ApiException catch (e) {
//       print('⚠️ API Error: ${e.message}');

//       // 👇 Try to parse the raw API response to show "details" message
//       String errorMessage = e.message;
//       try {
//         // Parse the JSON string from e.message if it contains full response
//         final RegExp jsonFinder = RegExp(r'\{.*\}');
//         final match = jsonFinder.firstMatch(e.message);
//         if (match != null) {
//           final jsonString = match.group(0)!;
//           final Map<String, dynamic> errorData = jsonDecode(jsonString);

//           if (errorData.containsKey('details') &&
//               errorData['details'] is List) {
//             errorMessage = errorData['details'].join('\n');
//           } else if (errorData.containsKey('details')) {
//             errorMessage = errorData['details'];
//           }
//         }
//       } catch (_) {
//         // If parsing fails, keep default message
//       }

//       _showErrorDialog("something went wrong");
//     } catch (e) {
//       print('❌ Unexpected error: $e');
//       _showErrorDialog('An unexpected error occurred. Please try again.');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ===================== UI HELPERS =====================
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===================== MAIN UI =====================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 40),
//                   Image.asset(
//                     'assets/images/zenzioicon.png',
//                     height: 90,
//                     errorBuilder: (context, error, stackTrace) =>
//                         const Text(
//                           'Zenzio',
//                           style: TextStyle(
//                             fontSize: 42,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Welcome Back!',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.secondary,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.background,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: TabBar(
//                       controller: _tabController,
//                       indicator: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       indicatorSize: TabBarIndicatorSize.tab,
//                       labelColor: AppColors.secondary,
//                       unselectedLabelColor: AppColors.textLight,
//                       labelStyle: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       tabs: const [
//                         Tab(text: 'Phone Number (OTP)'),
//                         Tab(text: 'Email & Password'),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   SizedBox(
//                     height: 360,
//                     child: TabBarView(
//                       controller: _tabController,
//                       children: [_buildPhoneLoginTab(), _buildEmailLoginTab()],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (_isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.3),
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================== PHONE LOGIN TAB =====================
//   Widget _buildPhoneLoginTab() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 80,
//               height: 56,
//               decoration: BoxDecoration(
//                 border: Border.all(color: const Color(0xFFE0E0E0)),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Center(
//                 child: DropdownButton<String>(
//                   value: _selectedCountryCode,
//                   underline: const SizedBox(),
//                   items: ['+1', '+91', '+44', '+61']
//                       .map(
//                         (code) => DropdownMenuItem(
//                           value: code,
//                           child: Text(
//                             code,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCountryCode = value!;
//                     });
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: TextField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 enabled: !_isLoading,
//                 decoration: _inputDecoration('Enter your mobile number'),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         CustomButton(
//           text: 'Continue',
//           onPressed: _handlePhoneLogin,
//           isLoading: _isLoading,
//         ),
//         const SizedBox(height: 16),
//         _buildSignUpText(),
//       ],
//     );
//   }

//   // ===================== EMAIL LOGIN TAB =====================
//   Widget _buildEmailLoginTab() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextField(
//           controller: _emailController,
//           keyboardType: TextInputType.emailAddress,
//           enabled: !_isLoading,
//           decoration: _inputDecoration('Enter your registered email'),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _passwordController,
//           obscureText: _obscurePassword,
//           enabled: !_isLoading,
//           decoration: _inputDecoration('Enter your password').copyWith(
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                 color: const Color(0xFF9E9E9E),
//               ),
//               onPressed: () {
//                 setState(() {
//                   _obscurePassword = !_obscurePassword;
//                 });
//               },
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Align(
//           alignment: Alignment.centerRight,
//           child: TextButton(
//             onPressed: _isLoading
//                 ? null
//                 : () {
//                     Navigator.pushNamed(context, '/forgot-password');
//                   },
//             style: TextButton.styleFrom(padding: EdgeInsets.zero),
//             child: const Text(
//               'Forgot Password?',
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         CustomButton(
//           text: 'Login',
//           onPressed: _handleEmailLogin,
//           isLoading: _isLoading,
//         ),
//         const SizedBox(height: 16),
//         _buildSignUpText(),
//       ],
//     );
//   }

//   // ===================== COMMON INPUT FIELD STYLE =====================
//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: AppColors.primary),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//     );
//   }

//   // ===================== SIGNUP TEXT =====================
//   Widget _buildSignUpText() {
//     return Center(
//       child: RichText(
//         text: TextSpan(
//           text: "Don't have an account? ",
//           style: const TextStyle(color: AppColors.textLight, fontSize: 14),
//           children: [
//             TextSpan(
//               text: 'Sign up',
//               style: const TextStyle(
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () {
//                   Navigator.pushNamed(context, '/signup');
//                 },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../../widgets/logo_widget.dart';
// import '../../widgets/custom_button.dart';
// import '../../core/constants/app_colors.dart';
// import '../../services/auth_service.dart';
// import '../../services/api_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   String _selectedCountryCode = '+1';

//   final AuthService _authService = AuthService();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _requestAppPermissions();
//     });
//   }

//   Future<void> _requestAppPermissions() async {
//     bool granted = await _requestPermissions();
//     if (!granted) {
//       _showPermissionDeniedDialog();
//     }
//   }

//   Future<bool> _requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.location,
//       Permission.camera,
//       Permission.photos,
//       Permission.storage,
//     ].request();

//     return statuses.values.every((status) => status.isGranted);
//   }

//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Permissions Required'),
//         content: const Text(
//           'This app needs location, camera, and gallery access to work properly.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               openAppSettings();
//               Navigator.pop(context);
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handlePhoneLogin() async {
//     final phone = _phoneController.text.trim();

//     if (phone.isEmpty) {
//       _showErrorDialog('Please enter your phone number');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       await _authService.sendOTP(
//         phone: phone,
//         countryCode: _selectedCountryCode,
//       );

//       setState(() => _isLoading = false);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('OTP sent successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         Navigator.pushNamed(
//           context,
//           '/otp',
//           arguments: {
//             'phone': phone,
//             'countryCode': _selectedCountryCode,
//           },
//         );
//       }
//     } on ApiException catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog(e.message);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog('An unexpected error occurred. Please try again.');
//     }
//   }

//   Future<void> _handleEmailLogin() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     if (email.isEmpty || password.isEmpty) {
//       _showErrorDialog('Please enter both email and password');
//       return;
//     }

//     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
//       _showErrorDialog('Please enter a valid email address');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final loginResponse = await _authService.loginWithEmail(
//         email: email,
//         password: password,
//       );

//       print('✅ Login response received: ${loginResponse.user?.name}');
//       setState(() => _isLoading = false);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Login successful!'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );

//         await Future.delayed(const Duration(milliseconds: 500));

//         if (mounted) {
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/main-navigation',
//             (route) => false,
//           );
//         }
//       }
//     } on ApiException catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog(e.message);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog('An unexpected error occurred. Please try again.');
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 40),
//                   const LogoWidget(),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Welcome Back!',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.secondary,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.background,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: TabBar(
//                       controller: _tabController,
//                       indicator: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       indicatorSize: TabBarIndicatorSize.tab,
//                       labelColor: AppColors.secondary,
//                       unselectedLabelColor: AppColors.textLight,
//                       labelStyle: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       tabs: const [
//                         Tab(text: 'Phone Number (OTP)'),
//                         Tab(text: 'Email & Password'),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   SizedBox(
//                     height: 360,
//                     child: TabBarView(
//                       controller: _tabController,
//                       children: [
//                         _buildPhoneLoginTab(),
//                         _buildEmailLoginTab(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (_isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.3),
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     valueColor:
//                         AlwaysStoppedAnimation<Color>(AppColors.primary),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPhoneLoginTab() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 80,
//               height: 56,
//               decoration: BoxDecoration(
//                 border: Border.all(color: const Color(0xFFE0E0E0)),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Center(
//                 child: DropdownButton<String>(
//                   value: _selectedCountryCode,
//                   underline: const SizedBox(),
//                   items: ['+1', '+91', '+44', '+61']
//                       .map((code) => DropdownMenuItem(
//                             value: code,
//                             child: Text(
//                               code,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedCountryCode = value!;
//                     });
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: TextField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 enabled: !_isLoading,
//                 decoration: _inputDecoration('Enter your mobile number'),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         CustomButton(
//           text: 'Continue',
//           onPressed: _handlePhoneLogin,
//           isLoading: _isLoading,
//         ),
//         const SizedBox(height: 16),
//         _buildSignUpText(),
//       ],
//     );
//   }

//   Widget _buildEmailLoginTab() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextField(
//           controller: _emailController,
//           keyboardType: TextInputType.emailAddress,
//           enabled: !_isLoading,
//           decoration: _inputDecoration('Enter your registered email'),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _passwordController,
//           obscureText: _obscurePassword,
//           enabled: !_isLoading,
//           decoration: _inputDecoration('Enter your password').copyWith(
//             suffixIcon: IconButton(
//               icon: Icon(
//                 _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                 color: const Color(0xFF9E9E9E),
//               ),
//               onPressed: () {
//                 setState(() {
//                   _obscurePassword = !_obscurePassword;
//                 });
//               },
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Align(
//           alignment: Alignment.centerRight,
//           child: TextButton(
//             onPressed: _isLoading
//                 ? null
//                 : () {
//                     Navigator.pushNamed(context, '/forgot-password');
//                   },
//             style: TextButton.styleFrom(padding: EdgeInsets.zero),
//             child: const Text(
//               'Forgot Password?',
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         CustomButton(
//           text: 'Login',
//           onPressed: _handleEmailLogin,
//           isLoading: _isLoading,
//         ),
//         const SizedBox(height: 16),
//         _buildSignUpText(),
//       ],
//     );
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: AppColors.primary),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//     );
//   }

//   Widget _buildSignUpText() {
//     return Center(
//       child: RichText(
//         text: TextSpan(
//           text: "Don't have an account? ",
//           style: const TextStyle(color: AppColors.textLight, fontSize: 14),
//           children: [
//             TextSpan(
//               text: 'Sign up',
//               style: const TextStyle(
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () {
//                   Navigator.pushNamed(context, '/signup');
//                 },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
