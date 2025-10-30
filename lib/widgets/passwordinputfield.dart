import 'package:flutter/material.dart';
import 'package:customer_app/core/constants/appcolors.dart'; // Ensure this path is correct

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;

  const PasswordInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  // A boolean to toggle password visibility
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _isObscure,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 18,
        ),
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryborder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryborder, width: 1.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryborder),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
      ),
    );
  }
}