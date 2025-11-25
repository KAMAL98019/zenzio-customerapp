import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppBackHandler extends StatelessWidget {
  final Widget child;

  const AppBackHandler({super.key, required this.child});

  Future<bool> _onBackPressed(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Exit App",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            child: const Text(
              "No",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text(
              "Yes",
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _onBackPressed(context);
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
