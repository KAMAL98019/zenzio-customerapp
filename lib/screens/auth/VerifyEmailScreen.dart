import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../auth/login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _loading = false;

  Future<void> _verifyEmail() async {
    setState(() => _loading = true);

    try {
     final response = await http.post(
  Uri.parse('${ApiConfig.baseUrl}/users/auth/send-verification-link'),
  body: {'email': widget.email},
);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Simulate backend verification (when user clicks link in email)
        await Future.delayed(const Duration(seconds: 3));

        // ✅ Redirect to Login after verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send verification link.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error sending verification link: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please verify your email address before continuing.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loading ? null : _verifyEmail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  backgroundColor: Colors.deepOrange,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify My Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../services/auth_service.dart';
// import '../../services/api_service.dart';

// class RegisterOTPVerifyScreen extends StatefulWidget {
//   const RegisterOTPVerifyScreen({super.key});

//   @override
//   State<RegisterOTPVerifyScreen> createState() => _RegisterOTPVerifyScreenState();
// }

// class _RegisterOTPVerifyScreenState extends State<RegisterOTPVerifyScreen> {
//   final List<TextEditingController> _otpControllers =
//       List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

//   final AuthService _authService = AuthService();
//   bool _isLoading = false;
//   int _resendTimer = 59;
//   Timer? _timer;

//   String _email = '';
//   String _mobile = '';
//   String _countryCode = '';

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final args = ModalRoute.of(context)?.settings.arguments;
//       if (args is Map) {
//         setState(() {
//           _email = (args['email'] ?? '').toString();
//           _mobile = (args['mobile'] ?? '').toString();
//           _countryCode = (args['countryCode'] ?? '').toString();
//         });
//       }
//     });
//   }

//   void _startTimer({int seconds = 59}) {
//     _timer?.cancel();
//     setState(() => _resendTimer = seconds);
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendTimer > 0) {
//         setState(() => _resendTimer--);
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     for (var c in _otpControllers) {
//       c.dispose();
//     }
//     for (var n in _focusNodes) {
//       n.dispose();
//     }
//     super.dispose();
//   }

//   void _onOtpChanged(int index, String value) {
//     if (value.length == 1 && index < 5) _focusNodes[index + 1].requestFocus();
//     if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
//   }

//   String get _enteredOtp => _otpControllers.map((c) => c.text.trim()).join();

//   Future<void> _verifyOtp() async {
//     final otp = _enteredOtp;
//     if (otp.length != 6) {
//       _showErrorDialog('Please enter the 6-digit OTP sent to your email or phone.');
//       return;
//     }

//     setState(() => _isLoading = true);
//     try {
//       final res = await _authService.verifyRegisterOTP(
//         email: _email,
//         phone: _mobile,
//         countryCode: _countryCode,
//         otp: otp,
//       );

//       setState(() => _isLoading = false);

//       if (res['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Verification successful! Please login to continue.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         _showErrorDialog(res['message'] ?? 'OTP verification failed');
//       }
//     } on ApiException catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog(e.message);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog('Unable to verify OTP. Please try again.');
//     }
//   }

//   Future<void> _resendOtp() async {
//     if (_resendTimer > 0) return;

//     setState(() => _isLoading = true);
//     try {
//       final res = await _authService.resendRegisterOTP(
//         email: _email,
//         phone: _mobile,
//         countryCode: _countryCode,
//       );

//       setState(() => _isLoading = false);

//       if (res['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(res['message'] ?? 'OTP resent successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         _startTimer(seconds: 59);
//         for (var c in _otpControllers) {
//           c.clear();
//         }
//         _focusNodes[0].requestFocus();
//       } else {
//         _showErrorDialog(res['message'] ?? 'Unable to resend OTP');
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showErrorDialog('Unable to resend OTP. Please try again.');
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
//       backgroundColor: const Color(0xFFFAFAFA),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Zenzio',
//           style: TextStyle(
//             color: Color(0xFFE53935),
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 40),
//                   const Text(
//                     'Verify Your Account',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     _email.isNotEmpty
//                         ? 'Enter the 6-digit code sent to $_email'
//                         : 'Enter the 6-digit code sent to your phone',
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Color(0xFF757575),
//                       height: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 40),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: List.generate(6, (index) {
//                       return SizedBox(
//                         width: 48,
//                         height: 56,
//                         child: TextField(
//                           controller: _otpControllers[index],
//                           focusNode: _focusNodes[index],
//                           textAlign: TextAlign.center,
//                           keyboardType: TextInputType.number,
//                           maxLength: 1,
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF2D2D2D),
//                           ),
//                           decoration: InputDecoration(
//                             counterText: '',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide:
//                                   const BorderSide(color: Color(0xFFE0E0E0)),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide:
//                                   const BorderSide(color: Color(0xFFE0E0E0)),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: const BorderSide(
//                                 color: Color(0xFFE53935),
//                                 width: 2,
//                               ),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                           ],
//                           onChanged: (value) => _onOtpChanged(index, value),
//                         ),
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     _resendTimer > 0
//                         ? 'Resend code in 0:${_resendTimer.toString().padLeft(2, '0')}'
//                         : 'Didn\'t receive the code?',
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Color(0xFF9E9E9E),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _verifyOtp,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE53935),
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text(
//                         'Verify',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   if (_resendTimer == 0)
//                     TextButton(
//                       onPressed: _isLoading ? null : _resendOtp,
//                       child: const Text(
//                         'Resend code',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFFE53935),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (_isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.35),
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
