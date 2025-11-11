import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zenzio_customer/services/api_service.dart';
import 'dart:async';

import '../../services/auth_service.dart';

class OTPVerifyScreen extends StatefulWidget {
  const OTPVerifyScreen({super.key});

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 59;
  Timer? _timer;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  String _phone = '';
  String _countryCode = '';
  bool _isNewUser = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Read arguments after first frame (so ModalRoute is available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        setState(() {
          _phone = (args['phone'] ?? '').toString();
          _countryCode = (args['countryCode'] ?? '').toString();
          _isNewUser = args['isNewUser'] == true;
        });
      }
    });
  }

  void _startTimer({int seconds = 59}) {
    _timer?.cancel();
    setState(() {
      _resendTimer = seconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _enteredOtp {
    return _otpControllers.map((c) => c.text.trim()).join();
  }

  Future<void> _verifyOtp() async {
    final otp = _enteredOtp;
    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      _showErrorDialog('Please enter the 6-digit OTP sent to your phone.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📦 Verifying OTP for $_phone');

      final res = await _authService.verifyOTP(
        phone: _phone,
        countryCode: _countryCode,
        otp: otp,
      );

      setState(() => _isLoading = false);
      print(res);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main-navigation',
        (route) => false,
      );
    } on ApiException catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.message);
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ verifyOtp error: $e');
      _showErrorDialog('Unable to verify OTP. Please try again.');
    }
  }

  Future<void> _resendOtp() async {
    if (_resendTimer > 0) return; // prevent spamming

    setState(() => _isLoading = true);

    try {
      final res = await _authService.resendOTP(
        phone: _phone,
        countryCode: _countryCode,
      );

      setState(() => _isLoading = false);

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'OTP resent successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset timer to 59 seconds
        _startTimer(seconds: 59);

        // Clear old OTP inputs for clarity
        for (var c in _otpControllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      } else {
        _showErrorDialog(res['message'] ?? 'Unable to resend OTP');
      }
    } on ApiException catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.message);
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ resendOtp error: $e');
      _showErrorDialog('Unable to resend OTP. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI preserved exactly as you provided
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Zenzio',
          style: TextStyle(
            color: Color(0xFFE53935),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Verify Your Mobile Number',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    // show phone partially masked for UX (if available)
                    _phone.isNotEmpty
                        ? 'Enter the 6-digit code sent to $_countryCode ${_phone.replaceRange(2, _phone.length - 2, 'XXXXXX')}\n'
                        : 'Enter the 6-digit code sent to your phone',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 56,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE53935),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) => _onOtpChanged(index, value),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _resendTimer > 0
                        ? 'Resend code in 0:${_resendTimer.toString().padLeft(2, '0')}'
                        : 'Didn\'t receive the code?',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_resendTimer == 0)
                    TextButton(
                      onPressed: _isLoading ? null : _resendOtp,
                      child: const Text(
                        'Resend code',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Having trouble? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // keep as-is; you can route to support page
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFE53935),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';

// class OTPVerifyScreen extends StatefulWidget {
//   const OTPVerifyScreen({super.key});

//   @override
//   State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
// }

// class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
//   final List<TextEditingController> _otpControllers =
//       List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
//   int _resendTimer = 59;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendTimer > 0) {
//         setState(() {
//           _resendTimer--;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _onOtpChanged(int index, String value) {
//     if (value.length == 1 && index < 5) {
//       _focusNodes[index + 1].requestFocus();
//     }
//     if (value.isEmpty && index > 0) {
//       _focusNodes[index - 1].requestFocus();
//     }
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
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 40),
//               const Text(
//                 'Verify Your Mobile Number',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2D2D2D),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Enter the 6-digit code sent to +91 XXXXX\nXXXXX',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Color(0xFF757575),
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(6, (index) {
//                   return SizedBox(
//                     width: 48,
//                     height: 56,
//                     child: TextField(
//                       controller: _otpControllers[index],
//                       focusNode: _focusNodes[index],
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       maxLength: 1,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF2D2D2D),
//                       ),
//                       decoration: InputDecoration(
//                         counterText: '',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFE53935),
//                             width: 2,
//                           ),
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                       ],
//                       onChanged: (value) => _onOtpChanged(index, value),
//                     ),
//                   );
//                 }),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Resend code in 0:${_resendTimer.toString().padLeft(2, '0')}',
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: Color(0xFF9E9E9E),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pushReplacementNamed(context, '/main-navigation');
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFE53935),
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     'Login',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Having trouble? ',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Color(0xFF757575),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: const Size(0, 0),
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: const Text(
//                       'Contact Support',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFFE53935),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
