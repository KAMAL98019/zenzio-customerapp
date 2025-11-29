import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  String _statusMessage = '';
  bool _isError = false;
  
  // ==================== COUNTDOWN TIMER ====================
  bool _canResend = true;
  int _remainingSeconds = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ==================== START COUNTDOWN ====================
  void _startCountdown() {
    setState(() {
      _remainingSeconds = 59;
      _canResend = false;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  // ==================== CHECK VERIFICATION STATUS ====================
  Future<void> _checkVerificationStatus() async {
    try {
      print('⚠️ Check verification endpoint not available yet');
    } catch (e) {
      print('⚠️ Could not check verification status: $e');
    }
  }

  // ==================== PARSE ERROR MESSAGE ====================
  String _parseErrorMessage(dynamic error) {
    try {
      String errorString = error.toString();
      
      // Check for TOO_MANY_ATTEMPTS in the error
      if (errorString.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
        return 'Too many verification emails sent. Please try again later.';
      }

      // Try to extract the details array
      if (errorString.contains('details')) {
        final RegExp detailsRegex = RegExp(r'"details":\s*\[(.*?)\]');
        final match = detailsRegex.firstMatch(errorString);
        
        if (match != null) {
          String detailsContent = match.group(1) ?? '';
          detailsContent = detailsContent.replaceAll(r'\"', '"');
          detailsContent = detailsContent.replaceAll(r'\\', '');
          
          if (detailsContent.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
            return 'Too many verification emails sent. Please try again later.';
          }
          
          return detailsContent.isNotEmpty 
              ? detailsContent 
              : 'Failed to send verification email';
        }
      }

      return 'Failed to send verification email. Please try again later.';
    } catch (e) {
      print('Error parsing error message: $e');
      return 'Failed to send verification email. Please try again later.';
    }
  }

  // ==================== RESEND VERIFICATION EMAIL ====================
  Future<void> _resendVerificationEmail() async {
    if (_isResending || !_canResend) return;

    setState(() {
      _isResending = true;
      _statusMessage = '';
      _isError = false;
    });

    try {
      final response = await ApiService().post(
        "/firebase/send-verification",
        body: {
          "email": widget.email,
          "redirectUrl": "https://zenzio.in"
        },
        requiresAuth: true,
      );

      if (!mounted) return;

      setState(() {
        _isResending = false;
        _statusMessage = 'Verification email sent successfully!';
        _isError = false;
      });

      // Start countdown after successful send
      _startCountdown();

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isResending = false;
        _statusMessage = _parseErrorMessage(e.toString());
        _isError = true;
      });

      // Start countdown even on error to prevent spam
      _startCountdown();
    }
  }

  // ==================== REFRESH STATUS ====================
  Future<void> _refreshVerificationStatus() async {
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Email Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 60,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Verify Your Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF757575),
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: 'We\'ve sent a verification link to\n',
                      ),
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const TextSpan(
                        text: '\n\nClick the link in your email to verify your account.',
                      ),
                    ],
                  ),
                ),

                // Status Message
                if (_statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _isError ? Colors.red.shade700 : Colors.green.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // ✅ Resend Email Button - With 60 second countdown
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: (_isResending || !_canResend) 
                        ? null 
                        : _resendVerificationEmail,
                    icon: _isResending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Color(0xFFE53935)),
                            ),
                          )
                        : Icon(
                            Icons.refresh, 
                            color: (!_canResend || _isResending)
                                ? Colors.grey 
                                : const Color(0xFFE53935),
                          ),
                    label: Text(
                      _isResending 
                          ? 'Sending...' 
                          : !_canResend 
                              ? 'Resend in ${_remainingSeconds}s'
                              : 'Resend Verification Email',
                      style: TextStyle(
                        color: (!_canResend || _isResending)
                            ? Colors.grey 
                            : const Color(0xFFE53935),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: (!_canResend || _isResending)
                            ? Colors.grey 
                            : const Color(0xFFE53935),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledForegroundColor: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Go to Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _refreshVerificationStatus,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: Text(
                      _isLoading ? 'Checking...' : 'Go to Login',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Didn\'t receive the email?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Check your spam/junk folder\n'
                        '• Make sure ${widget.email} is correct\n'
                        '• Click "Resend" to get a new email\n'
                        '• Wait a few minutes for delivery',
                        style: TextStyle(
                          fontSize: 13, 
                          color: Colors.blue.shade700,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//  final
// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
// import '../auth/login_screen.dart';

// class VerifyEmailScreen extends StatefulWidget {
//   final String email;
//   const VerifyEmailScreen({super.key, required this.email});

//   @override
//   State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
//   bool _isLoading = false;
//   bool _isResending = false;
//   String _statusMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     // Optionally check email verification status on load
//     _checkVerificationStatus();
//   }

//   // ==================== CHECK VERIFICATION STATUS ====================
//   Future<void> _checkVerificationStatus() async {
//     try {
//       final response = await ApiService().get(
//         "/firebase/check-verification?email=${widget.email}",
//         requiresAuth: true,
//       );

//       if (!mounted) return;

//       if (response['verified'] == true) {
//         setState(() {
//           _statusMessage = 'Email already verified!';
//         });
        
//         // Auto-redirect to login after a delay
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const LoginScreen()),
//             );
//           }
//         });
//       }
//     } catch (e) {
//       // Ignore errors - user might not be verified yet
//       print('⚠️ Could not check verification status: $e');
//     }
//   }

//   // ==================== RESEND VERIFICATION EMAIL ====================
//   Future<void> _resendVerificationEmail() async {
//     setState(() {
//       _isResending = true;
//       _statusMessage = '';
//     });

//     try {
//       final response = await ApiService().post(
//         "/firebase/send-verification",
//         body: {
//           "email": widget.email,
//           "redirectUrl": "https://zenzio-39b9d.firebaseapp.com/__/auth/action"
//         },
//         requiresAuth: true,
//       );

//       if (!mounted) return;

//       setState(() => _isResending = false);

//       if (response['success'] == true ||
//           response['status'] == 200 ||
//           response['status'] == 201) {
//         setState(() {
//           _statusMessage = 'Verification email sent successfully!';
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Verification email sent! Please check your inbox.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         throw Exception(response['message'] ?? 'Failed to send email');
//       }
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isResending = false;
//         _statusMessage = 'Failed to send email. Please try again.';
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // ==================== REFRESH STATUS ====================
//   Future<void> _refreshVerificationStatus() async {
//     setState(() => _isLoading = true);
    
//     await _checkVerificationStatus();
    
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFAFA),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
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
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Email Icon
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.email_outlined,
//                   size: 60,
//                   color: Colors.orangeAccent,
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Title
//               const Text(
//                 'Verify Your Email',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Description
//               RichText(
//                 textAlign: TextAlign.center,
//                 text: TextSpan(
//                   style: const TextStyle(
//                     fontSize: 15,
//                     color: Color(0xFF757575),
//                     height: 1.5,
//                   ),
//                   children: [
//                     const TextSpan(
//                       text: 'We\'ve sent a verification link to\n',
//                     ),
//                     TextSpan(
//                       text: widget.email,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF2D2D2D),
//                       ),
//                     ),
//                     const TextSpan(
//                       text: '\n\nClick the link in your email to verify your account.',
//                     ),
//                   ],
//                 ),
//               ),

//               // Status Message
//               if (_statusMessage.isNotEmpty) ...[
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: _statusMessage.contains('already verified') ||
//                             _statusMessage.contains('successfully')
//                         ? Colors.green.shade50
//                         : Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     _statusMessage,
//                     style: TextStyle(
//                       color: _statusMessage.contains('already verified') ||
//                               _statusMessage.contains('successfully')
//                           ? Colors.green.shade700
//                           : Colors.red.shade700,
//                       fontSize: 14,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],

//               const SizedBox(height: 40),

//               // Resend Email Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: OutlinedButton.icon(
//                   onPressed: _isResending ? null : _resendVerificationEmail,
//                   icon: _isResending
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation(Color(0xFFE53935)),
//                           ),
//                         )
//                       : const Icon(Icons.refresh, color: Color(0xFFE53935)),
//                   label: Text(
//                     _isResending ? 'Sending...' : 'Resend Verification Email',
//                     style: const TextStyle(
//                       color: Color(0xFFE53935),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Color(0xFFE53935)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Check Verification Status Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton.icon(
//                   onPressed: _isLoading ? null : _refreshVerificationStatus,
//                   icon: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation(Colors.white),
//                           ),
//                         )
//                       : const Icon(Icons.check_circle_outline, color: Colors.white),
//                   label: Text(
//                     _isLoading ? 'Checking...' : 'I\'ve Verified My Email',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFE53935),
//                     disabledBackgroundColor: Colors.grey[300],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Go to Login
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginScreen()),
//                   );
//                 },
//                 child: const Text(
//                   'Go to Login',
//                   style: TextStyle(
//                     color: Color(0xFF757575),
//                     fontSize: 16,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Instructions
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue.shade100),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.info_outline, 
//                              size: 20, 
//                              color: Colors.blue.shade700),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Didn\'t receive the email?',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             color: Colors.blue.shade700,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       '• Check your spam/junk folder\n'
//                       '• Make sure ${widget.email} is correct\n'
//                       '• Click "Resend" to get a new email\n'
//                       '• Wait a few minutes for delivery',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.blue.shade700,
//                         height: 1.6,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
