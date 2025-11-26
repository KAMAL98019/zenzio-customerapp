import 'package:flutter/material.dart';

class ResetLinkSentScreen extends StatelessWidget {
  const ResetLinkSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GET EMAIL FROM ARGUMENTS
    final String email = ModalRoute.of(context)?.settings.arguments as String? ?? "your email";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // BEAUTIFUL ROUND ICON
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_rounded,
                color: const Color(0xFFE53935),
                size: 60,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Password Reset Link Sent!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // DYNAMIC EMAIL DISPLAY
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: "We have sent a password reset link to\n"),
                  TextSpan(
                    text: email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const TextSpan(
                    text: "\nPlease check your inbox to reset your password.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Go to Login",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Extra Info Box
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
                      Icon(Icons.info_outline,
                          size: 20, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Didn’t receive the email?',
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
                    "• Check your spam/junk folder\n"
                    "• Make sure your email is correct\n"
                    "• Wait a few minutes for delivery",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
