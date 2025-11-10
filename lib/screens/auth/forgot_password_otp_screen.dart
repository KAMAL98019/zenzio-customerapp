import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zenzio_customer/services/auth_service.dart';
import 'dart:async';

class ForgotPasswordOTPScreen extends StatefulWidget {
  const ForgotPasswordOTPScreen({super.key});

  @override
  State<ForgotPasswordOTPScreen> createState() =>
      _ForgotPasswordOTPScreenState();
}

class _ForgotPasswordOTPScreenState extends State<ForgotPasswordOTPScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final AuthService _authService = AuthService();
  int _resendTimer = 59;
  Timer? _timer;
  bool _isLoading = false;

  late final String input;
  late final bool isEmail;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    input = args?['input'] ?? '';
    isEmail = args?['isEmail'] ?? false;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
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
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showSnackBar('Please enter the full 6-digit OTP', false);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.verifyForgotPasswordOTP(
      input: input,
      otp: otp,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar(result['message'], true);
      Navigator.pushNamed(context, '/reset-password');
    } else {
      _showSnackBar(result['message'], false);
    }
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Verify Your Mobile Number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to ${isEmail ? input : "+91 ${input.substring(0, 2)}XXXXX${input.substring(input.length - 3)}"}',
                style: const TextStyle(
                  fontSize: 14,
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
                'Resend code in 0:${_resendTimer.toString().padLeft(2, '0')}',
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
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
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
                    onPressed: () {},
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
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';

// class ForgotPasswordOTPScreen extends StatefulWidget {
//   const ForgotPasswordOTPScreen({super.key});

//   @override
//   State<ForgotPasswordOTPScreen> createState() =>
//       _ForgotPasswordOTPScreenState();
// }

// class _ForgotPasswordOTPScreenState extends State<ForgotPasswordOTPScreen> {
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
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Choozy',
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
//                   fontSize: 24,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2D2D2D),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Enter the 6-digit code sent to +91 XXXXX\nXXXXX',
//                 style: TextStyle(
//                   fontSize: 14,
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
//                           borderSide: const BorderSide(
//                             color: Color(0xFFE53935),
//                             width: 2,
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFE0E0E0),
//                           ),
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
//                     Navigator.pushNamed(context, '/reset-password');
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
//                     'Verify',
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
