import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFFFA726), // Orange
          Color(0xFFFFEB3B), // Yellow
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: const Text(
        'Zenzio',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class LogoWidget extends StatelessWidget {
//   const LogoWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 120, // Adjust size as you like
//       child: Image.asset(
//         'assets/images/zenzioicon_copy.png',
//         fit: BoxFit.contain,
//       ),
//     );
//   }
// }
