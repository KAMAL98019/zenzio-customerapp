import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zenzio_customer/screens/auth/VerifyEmailScreen.dart';
import 'package:zenzio_customer/screens/home/home1_screen.dart';
import 'package:zenzio_customer/widgets/app_back_handler.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_verify_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/forgot_password_otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home/main_navigation_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/home/restaurant_detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/cart/cart_rest_screen.dart'; 
import 'screens/myOrder/order_tracking_screen.dart';
import 'screens/myOrder/my_orders_screen.dart';
import 'screens/myOrder/order_details_screen.dart';
import 'screens/booking/bookings_home_screen.dart';
import 'screens/booking/booking_detail_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/booking/booking_confirmation_screen.dart';
import 'screens/myOrder/booking_details_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/saved_addresses_screen.dart';
import 'screens/profile/add_edit_address_screen.dart';
import 'screens/profile/payment_methods_screen.dart';
import 'screens/profile/notifications_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/chat_assistant_screen.dart';
import 'screens/profile/my_coupons_screen.dart';
import 'services/auth_service.dart';

bool _permissionsRequested = false;

// ✅ Initialize auth service before app starts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
     requestInitialPermissions();

  // Initialize auth service to load token
  await AuthService().initialize();
  
  runApp(const ZenzioApp());
}


  Future<void> requestInitialPermissions() async {
  if (_permissionsRequested) return; // prevents duplicate dialog
  _permissionsRequested = true;

  await [
    Permission.location,
    Permission.camera,
    Permission.photos,
    Permission.storage,
  ].request();
}
  class ZenzioApp extends StatelessWidget {
    const ZenzioApp({super.key});


  @override
  Widget build(BuildContext context) {
    return AppBackHandler(
      child: MaterialApp(
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
        // '/register-otp-verify': (context) => const RegisterOTPVerifyScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/forgot-otp': (context) => const ForgotPasswordOTPScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        
        // Main Navigation
        '/main-navigation': (context) => const MainNavigationScreen(),
        
        // Food Ordering Flow
        '/home1': (context) => const RestaurantListScreen(),
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
       '/booking-details': (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

  return BookingDetailsScreen(
    bookingId: args?['bookingId'] ?? '',
    userId: args?['userId'] ?? '',
  );
},


        '/booking-form': (context) => const BookingFormScreen(),
        '/booking-confirmation': (context) => const BookingConfirmationScreen(),
        
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
      
      //      onGenerateRoute: (settings) {
      //   if (settings.name == '/booking-details') {
      //     // final args = settings.arguments as Map<String, dynamic>;
      //     return MaterialPageRoute(
      //       builder: (context) => BookingDetailsScreen(
      //         bookingId: args['bookingId'],
      //         userId: args['userId'],
      //       ),
      //     );
      //   }

      //   return null;
      // },
      )
    );
  }
}