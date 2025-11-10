// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _resetPassword() async {
//     final newPassword = _newPasswordController.text.trim();
//     final confirmPassword = _confirmPasswordController.text.trim();

//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showMessage('Please enter all fields');
//       return;
//     }
//     if (newPassword != confirmPassword) {
//       _showMessage('Passwords do not match');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Replace with the actual email or mobile passed from previous screen
//       const emailOrMobile = 'john@example.com';

//       final url = Uri.parse(
//           'https://backend.zenzio.in/api/users/auth/forgot-password/reset-password');
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'emailOrMobile': emailOrMobile,
//           'newPassword': newPassword,
//         }),
//       );

//       setState(() {
//         _isLoading = false;
//       });

//       if (response.statusCode == 200) {
//         _showSuccessDialog();
//       } else {
//         final error = jsonDecode(response.body)['message'] ??
//             'Failed to reset password';
//         _showMessage(error);
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showMessage('Something went wrong. Please try again.');
//     }
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         title: const Text(
//           'Success',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//         ),
//         content: const Text(
//           'Your password has been reset successfully.',
//           style: TextStyle(fontSize: 14),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).popUntil((route) => route.isFirst);
//             },
//             child: const Text(
//               'OK',
//               style: TextStyle(
//                   color: Color(0xFFE53935), fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
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
//               color: Color(0xFFE53935),
//               fontSize: 16,
//               fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 40),
//                 const Text(
//                   'Set New Password',
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D)),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Please enter your new password below.',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF757575),
//                     height: 1.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 40),
//                 // New Password
//                 TextField(
//                   controller: _newPasswordController,
//                   obscureText: _obscureNewPassword,
//                   decoration: InputDecoration(
//                     hintText: 'Enter new password',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscureNewPassword
//                           ? Icons.visibility_off
//                           : Icons.visibility),
//                       onPressed: () {
//                         setState(() {
//                           _obscureNewPassword = !_obscureNewPassword;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 // Confirm Password
//                 TextField(
//                   controller: _confirmPasswordController,
//                   obscureText: _obscureConfirmPassword,
//                   decoration: InputDecoration(
//                     hintText: 'Confirm new password',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscureConfirmPassword
//                           ? Icons.visibility_off
//                           : Icons.visibility),
//                       onPressed: () {
//                         setState(() {
//                           _obscureConfirmPassword = !_obscureConfirmPassword;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _resetPassword,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE53935),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                     child: _isLoading
//                         ? const CircularProgressIndicator(
//                             color: Colors.white,
//                           )
//                         : const Text(
//                             'Reset Password',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.w600),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
          'Choozy',
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Set New Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please enter your new password below.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    hintStyle: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 14,
                    ),
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
                      borderSide: const BorderSide(color: Color(0xFFE53935)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF9E9E9E),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm new password',
                    hintStyle: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 14,
                    ),
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
                      borderSide: const BorderSide(color: Color(0xFFE53935)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF9E9E9E),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Show success dialog and navigate back to login
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: const Text(
                            'Success',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: const Text(
                            'Your password has been reset successfully.',
                            style: TextStyle(fontSize: 14),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
