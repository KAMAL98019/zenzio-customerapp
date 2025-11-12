import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:zenzio_customer/screens/auth/VerifyEmailScreen.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  String _selectedGender = 'Male';
  String _selectedCountryCode = '+91';
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _birthdayController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE53935)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  // ==================== SEND OTP ====================
  Future<void> _sendOtp() async {
    if (_mobileController.text.trim().isEmpty) {
      _showErrorDialog("Please enter your mobile number");
      return;
    }

    if (_mobileController.text.trim().length < 10) {
      _showErrorDialog("Please enter a valid mobile number");
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      if (_isOtpSent) {
        // Resend OTP
        final result = await _authService.resendOTP(
          phone: _mobileController.text.trim(),
          countryCode: _selectedCountryCode,
        );

        if (!mounted) return; // ✅ Check if widget is still mounted

        setState(() => _isSendingOtp = false);

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP resent successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showErrorDialog(result['message'] ?? "Failed to resend OTP");
        }
      } else {
        // Send OTP for first time
        await _authService.sendOTP(
          phone: _mobileController.text.trim(),
          countryCode: _selectedCountryCode,
        );

        if (!mounted) return; // ✅ Check if widget is still mounted

        setState(() {
          _isOtpSent = true;
          _isSendingOtp = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP sent successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // ✅ Check before showing error
      
      setState(() => _isSendingOtp = false);
      _showErrorDialog("Failed to send OTP. Please try again.");
    }
  }

  // ==================== VERIFY OTP ====================
  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      _showErrorDialog("Please enter OTP");
      return;
    }

    if (_otpController.text.trim().length < 4) {
      _showErrorDialog("Please enter a valid OTP");
      return;
    }

    setState(() => _isVerifyingOtp = true);

    try {
      await _authService.verifyOTP(
        phone: _mobileController.text.trim(),
        countryCode: _selectedCountryCode,
        otp: _otpController.text.trim(),
      );

      if (!mounted) return; // ✅ Check if widget is still mounted

      setState(() {
        _isOtpVerified = true;
        _isVerifyingOtp = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mobile number verified successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return; // ✅ Check before showing dialog
      
      setState(() => _isVerifyingOtp = false);
      _showErrorDialog("Invalid OTP. Please try again.");
    }
  }

  // ==================== SIGNUP ====================
  Future<void> _handleSignup() async {
    // Validate all fields
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog("Please enter your first name");
      return;
    }

    if (_lastNameController.text.trim().isEmpty) {
      _showErrorDialog("Please enter your last name");
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog("Please enter your email address");
      return;
    }

    if (!_isOtpVerified) {
      _showErrorDialog("Please verify your mobile number first");
      return;
    }

    if (_birthdayController.text.trim().isEmpty) {
      _showErrorDialog("Please select your birthday");
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showErrorDialog("Please enter a password");
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      _showErrorDialog("Password must be at least 6 characters");
      return;
    }

    if (!_agreeToTerms) {
      _showErrorDialog("Please agree to the terms and conditions");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _mobileController.text.trim(),
        countryCode: _selectedCountryCode,
        dateOfBirth: _birthdayController.text.trim(),
        gender: _selectedGender,
      );

      if (!mounted) return; // ✅ Check if widget is still mounted

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return; // ✅ Check before updating UI

      setState(() => _isLoading = false);

      String errorMessage = 'An unexpected error occurred. Please try again.';

      if (e is ApiException) {
        try {
          final Map<String, dynamic> errorData = jsonDecode(e.message);

          if (errorData['details'] != null &&
              errorData['details'] is List &&
              (errorData['details'] as List).isNotEmpty) {
            errorMessage = (errorData['details'] as List).join('\n');
          } else if (errorData['details'] is String) {
            errorMessage = errorData['details'];
          } else {
            errorMessage = e.message;
          }
        } catch (_) {
          try {
            final Map<String, dynamic> fallback = jsonDecode(e.toString());
            if (fallback['details'] != null &&
                fallback['details'] is List &&
                (fallback['details'] as List).isNotEmpty) {
              errorMessage = (fallback['details'] as List).join('\n');
            } else {
              errorMessage = fallback['message'] ?? e.toString();
            }
          } catch (_) {
            errorMessage = e.toString();
          }
        }
      }

      _showErrorDialog(errorMessage);
    }
  }

  // ==================== UI HELPERS ====================
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

  // ==================== UI BUILD ====================
  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 32),

                // === First Name ===
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Enter your first name',
                ),
                const SizedBox(height: 16),

                // === Last Name ===
                _buildTextField(
                  controller: _lastNameController,
                  hintText: 'Enter your last name',
                ),
                const SizedBox(height: 16),

                // === Email ===
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // === Password ===
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Create a password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF9E9E9E),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),

                // === Mobile + Send OTP Button ===
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          underline: const SizedBox(),
                          items: ['+91', '+1', '+44', '+61']
                              .map((code) => DropdownMenuItem(
                                    value: code,
                                    child: Text(code),
                                  ))
                              .toList(),
                          onChanged: _isOtpVerified
                              ? null
                              : (value) =>
                                  setState(() => _selectedCountryCode = value!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _mobileController,
                        hintText: 'Enter your mobile number',
                        keyboardType: TextInputType.phone,
                        enabled: !_isOtpVerified,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_isSendingOtp || _isOtpVerified)
                            ? null
                            : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: _isSendingOtp
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                _isOtpVerified
                                    ? "Verified"
                                    : (_isOtpSent ? "Resend" : "Send OTP"),
                                style: TextStyle(
                                  color: _isOtpVerified
                                      ? Colors.grey[600]
                                      : Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                // === OTP Input + Verify Button (shown after OTP sent) ===
                if (_isOtpSent && !_isOtpVerified) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _otpController,
                          hintText: "Enter OTP",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isVerifyingOtp ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: _isVerifyingOtp
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  "Verify",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],

                // === Birthday (only shown after OTP verified) ===
                if (_isOtpVerified) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _birthdayController,
                    hintText: 'Select your birthday',
                    readOnly: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today,
                          color: Color(0xFF9E9E9E), size: 20),
                      onPressed: () => _selectDate(context),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),

                  // === Gender Dropdown ===
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF9E9E9E),
                      ),
                      hint: const Text(
                        'Select your gender',
                        style: TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D2D2D),
                      ),
                      items: ['Male', 'Female', 'Other', 'Prefer not to say']
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedGender = value!),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // === Terms ===
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) =>
                            setState(() => _agreeToTerms = value ?? false),
                        activeColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to the ',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF757575),
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // === Signup Button ===
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleSignup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // === Login Link ===
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // === Loading Overlay ===
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFE53935)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
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
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}