import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isVerified = false;
  bool _isLoading = false;

  // SEND VERIFICATION EMAIL
  Future<void> _verifyEmail() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService().post(
        "/firebase/send-verification",
        body: {
          "email": widget.email,
          "redirectUrl": "https://zenzio-39b9d.firebaseapp.com/__/auth/action"
        },
        requiresAuth: false,    // FIXED!
      );

      if (response['success'] == true ||
          response['status'] == 200 ||
          response['status'] == 201) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent')),
        );

        setState(() {
          _isVerified = true;
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _isVerified
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isVerified ? Icons.check_circle : Icons.email_outlined,
                  size: 60,
                  color:
                      _isVerified ? Colors.green.shade600 : Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                _isVerified
                    ? 'Verification Email Sent!'
                    : 'Please Verify Your Email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _isVerified
                    ? 'A verification email has been sent to\n${widget.email}'
                    : 'We have sent a verification email to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _verifyEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Send Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Go to Login Now',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


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
//   bool _isVerified = false;
//   bool _isLoading = false;

//   Future<void> _verifyEmail() async {
//     setState(() => _isLoading = true);

//     try {
//       // Call your backend endpoint (Firebase sends verification)
//       final response = await ApiService().post(
//         "/firebase/send-verification",
//         body: {},
//         requiresAuth: true,
//       );

//       if (response['success'] == true || response['status'] == 201) {
//         // Simulate verification success (in real flow, this happens after clicking email link)
//         await Future.delayed(const Duration(seconds: 2));
//         setState(() {
//           _isVerified = true;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed: ${response['message']}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sending verification: $e')),
//       );
//     } finally {
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
//               // Icon changes based on verification state
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: _isVerified
//                       ? Colors.green.shade50
//                       : Colors.orange.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   _isVerified ? Icons.check_circle : Icons.email_outlined,
//                   size: 60,
//                   color:
//                       _isVerified ? Colors.green.shade600 : Colors.orangeAccent,
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Title changes based on state
//               Text(
//                 _isVerified
//                     ? 'Account Verified Successfully!'
//                     : 'Please Verify Your Email',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2D2D2D),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Message
//               Text(
//                 _isVerified
//                     ? 'Your account has been verified for\n${widget.email}'
//                     : 'We have sent a verification email to\n${widget.email}',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   color: Color(0xFF757575),
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               // Verify Email Button (always visible)
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _verifyEmail,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : const Text(
//                         'Verify Email',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//               ),

//               const SizedBox(height: 20),

//               // Go to Login Now button (always below)
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginScreen()),
//                   );
//                 },
//                 child: const Text(
//                   'Go to Login Now',
//                   style: TextStyle(
//                     color: Color(0xFFE53935),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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
//   bool _isVerified = false;
//   bool _isLoading = false;

//   Future<void> _verifyEmail() async {
//     setState(() => _isLoading = true);

//     try {
//       // Call your backend endpoint (Firebase sends verification)
//       final response = await ApiService().post(
//         "/firebase/send-verification",
//         body: {},
//         requiresAuth: true,
//       );

//       if (response['success'] == true || response['status'] == 201) {
//         // Simulate verification success (in real flow, this happens after clicking email link)
//         await Future.delayed(const Duration(seconds: 2));
//         setState(() {
//           _isVerified = true;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed: ${response['message']}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sending verification: $e')),
//       );
//     } finally {
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
//               // Icon changes based on verification state
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: _isVerified
//                       ? Colors.green.shade50
//                       : Colors.orange.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   _isVerified ? Icons.check_circle : Icons.email_outlined,
//                   size: 60,
//                   color:
//                       _isVerified ? Colors.green.shade600 : Colors.orangeAccent,
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Title changes based on state
//               Text(
//                 _isVerified
//                     ? 'Account Verified Successfully!'
//                     : 'Please Verify Your Email',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2D2D2D),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Message
//               Text(
//                 _isVerified
//                     ? 'Your account has been verified for\n${widget.email}'
//                     : 'We have sent a verification email to\n${widget.email}',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   color: Color(0xFF757575),
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               // Conditional Button
//               _isVerified
//                   ? TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => const LoginScreen()),
//                         );
//                       },
//                       child: const Text(
//                         'Go to Login Now',
//                         style: TextStyle(
//                           color: Color(0xFFE53935),
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     )
//                   : ElevatedButton(
//                       onPressed: _isLoading ? null : _verifyEmail,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE53935),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 40, vertical: 14),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : const Text(
//                               'Verify Email',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
