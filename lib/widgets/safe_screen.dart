// import 'package:flutter/material.dart';

// /// Wrapper that catches all errors in child screens
// class SafeScreen extends StatefulWidget {
//   final Widget Function() builder;
//   final String screenName;

//   const SafeScreen({
//     super.key,
//     required this.builder,
//     required this.screenName,
//   });

//   @override
//   State<SafeScreen> createState() => _SafeScreenState();
// }

// class _SafeScreenState extends State<SafeScreen> {
//   Object? _error;
// @override
// Widget build(BuildContext context) {
//   if (_error != null) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.screenName} Error'),
//         backgroundColor: Colors.red,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               Text(
//                 'Error in ${widget.screenName}',
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _error.toString(),
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _error = null;
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
//                 child: const Text('Retry'),
//               ),
//               const SizedBox(height: 8),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     '/main-navigation',
//                     (route) => false,
//                   );
//                 },
//                 child: const Text('Go to Home'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ✅ Just assign the global handler — don’t return it
//   ErrorWidget.builder = (FlutterErrorDetails details) {
//     setState(() {
//       _error = details.exception;
//     });
//     print('❌ Error in ${widget.screenName}: ${details.exception}');
//     print('📍 Stack: ${details.stack}');
//     return const SizedBox(); // temporary empty widget
//   };

//   try {
//     print('🔍 Building ${widget.screenName}...');
//     final screen = widget.builder();
//     print('✅ ${widget.screenName} built successfully');
//     return screen;
//   } catch (e, stackTrace) {
//     print('❌ Error building ${widget.screenName}: $e');
//     print('📍 Stack trace: $stackTrace');
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         setState(() {
//           _error = e;
//         });
//       }
//     });
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
// }