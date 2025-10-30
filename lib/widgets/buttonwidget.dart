import 'package:flutter/material.dart';
import 'package:customer_app/core/constants/appcolors.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const ButtonWidget({
    Key? key,
    required this.onPressed,
    this.text = 'Continue',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // ✅ Full width button
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed, // ✅ Use the callback passed from parent
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
