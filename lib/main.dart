import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/otp_verify_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/forgot_password_otp_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/restaurant_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/cart_rest_screen.dart'; // ✅ NEW: Import the restaurant cart screen
import 'screens/order_tracking_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/order_details_screen.dart';
import 'screens/bookings_home_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/booking_form_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/booking_details_screen.dart';

import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/saved_addresses_screen.dart';
import 'screens/add_edit_address_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/chat_assistant_screen.dart';
import 'screens/my_coupons_screen.dart';

// ✅ Import auth service
import 'services/auth_service.dart';

// ✅ Initialize auth service before app starts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize auth service to load token
  await AuthService().initialize();
  
  runApp(const ZenzioApp());
}

class ZenzioApp extends StatelessWidget {
  const ZenzioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenzio - Food Delivery & Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          primary: const Color(0xFFE53935),
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        // Auth Flow
        '/': (context) => const LoginScreen(),
        '/otp': (context) => const OTPVerifyScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/forgot-otp': (context) => const ForgotPasswordOTPScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        
        // Main Navigation
        '/main-navigation': (context) => const MainNavigationScreen(),
        
        // Food Ordering Flow
        '/home': (context) => const HomeScreen(),
        '/menu': (context) => const MenuScreen(),
        '/restaurant-detail': (context) => const RestaurantDetailScreen(
          restaurantId: '',
        ),
        
        // ✅ NEW: Restaurant cart overview (shows list of restaurants)
        '/cart-rest': (context) => const CartRestScreen(),
        
        // ✅ Cart detail (shows items from a restaurant)
        '/cart': (context) => const CartScreen(),
        
        // '/checkout': (context) => const CheckoutScreen(),
        // '/order-tracking': (context) => const OrderTrackingScreen(),
        '/my-orders': (context) => const MyOrdersScreen(),
        '/order-details': (context) => const OrderDetailsScreen(),
        '/order-tracking':(context)=>const OrderTrackingScreen(orderId: null,),
        // Booking Flow
        '/bookings': (context) => const BookingsHomeScreen(),
        '/booking-detail': (context) => const BookingDetailScreen(),
        '/booking-form': (context) => const BookingFormScreen(),
        '/booking-confirmation': (context) => const BookingConfirmationScreen(),
        '/booking-details': (context) => const BookingDetailsScreen(),
        
        // Profile Flow
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/saved-addresses': (context) => const SavedAddressesScreen(),
        '/add-address': (context) => const AddEditAddressScreen(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/help-support': (context) => const HelpSupportScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/chat-assistant': (context) => const ChatAssistantScreen(),
        '/my-coupons': (context) => const MyCouponsScreen(),
      },
    );
  }
}