import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/core/theme/app_theme.dart';
import 'package:customer_app/screens/cart_service.dart';
import 'package:customer_app/widgets/bottomnavigationbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:customer_app/screens/auth/login.dart';
import 'package:provider/provider.dart';
import 'screens/cartpage.dart'; // Optional: if you want to test CartPage

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()), // ✅ Add your CartService
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const LoginPageState(),
      // To directly test CartPage, you can temporarily use:
      // home: const CartPage(),
    );
  }
}
