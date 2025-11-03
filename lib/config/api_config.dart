// lib/config/api_config.dart
class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://backend.zenzio.in';
  static const String apiVersion = '/api';
  
  // Full API Base
  static const String apiBaseUrl = '$baseUrl$apiVersion';
  
  // ==================== AUTH ENDPOINTS ====================
  static const String loginEndpoint = '$apiVersion/users/auth/login';
  // static const String signupEndpoint = '$apiVersion/auth/signup';
static const String signupEndpoint = '$apiVersion/users';
  static const String otpSendEndpoint = '$apiVersion/auth/send-otp';
  static const String otpVerifyEndpoint = '$apiVersion/auth/verify-otp';
  static const String forgotPasswordEndpoint = '$apiVersion/auth/forgot-password';
  static const String resetPasswordEndpoint = '$apiVersion/auth/reset-password';
  static const String logoutEndpoint = '$apiVersion/auth/logout';
  

    static const String foodItemsEndpoint = '$baseUrl/food-items';

  // ==================== USER ENDPOINTS ====================
  static const String usersEndpoint = '$apiVersion/users';
  static const String userProfileEndpoint = '$apiVersion/users/me';
  static const String updateProfileEndpoint = '$apiVersion/users/{userId}';
  
  // ==================== RESTAURANT ENDPOINTS ====================
  static const String restaurantsEndpoint = '$apiVersion/restaurants';
  static String restaurantDetailEndpoint(String id) => '$apiVersion/restaurants/$id';
  static String restaurantMenuEndpoint(String id) => '$apiVersion/restaurants/$id/menu';
  
  // ==================== ORDER ENDPOINTS ====================
  static const String ordersEndpoint = '$apiVersion/orders';
  static String orderDetailEndpoint(String id) => '$apiVersion/orders/$id';
  static String orderTrackingEndpoint(String id) => '$apiVersion/orders/$id/tracking';
  
  // ==================== BOOKING ENDPOINTS ====================
  static const String bookingsEndpoint = '$apiVersion/bookings';
  static String bookingDetailEndpoint(String id) => '$apiVersion/bookings/$id';
  
  // ==================== ADDRESS ENDPOINTS ====================
  static const String addressesEndpoint = '$apiVersion/addresses';
  static String addressDetailEndpoint(String id) => '$apiVersion/addresses/$id';
  // ==================== CART ENDPOINTS ====================
static const String cartEndpoint = '$apiBaseUrl/cart';
static const String addToCartEndpoint = '$apiBaseUrl/carts/items';
static const String updateCartEndpoint = '$apiBaseUrl/carts/update';
static const String removeFromCartEndpoint = '$apiBaseUrl/carts/remove';
static const String clearCartEndpoint = '$apiBaseUrl/carts/clear';

  
  // ==================== PAYMENT ENDPOINTS ====================
  static const String paymentMethodsEndpoint = '$apiVersion/payment-methods';
  static const String processPaymentEndpoint = '$apiVersion/payments/process';
  
  // ==================== COUPON ENDPOINTS ====================
  static const String couponsEndpoint = '$apiVersion/coupons';
  static const String applyCouponEndpoint = '$apiVersion/coupons/apply';
  
  // ==================== NOTIFICATION ENDPOINTS ====================
  static const String notificationsEndpoint = '$apiVersion/notifications';
  static String markNotificationReadEndpoint(String id) => '$apiVersion/notifications/$id/read';
  
  // ==================== HEADERS ====================
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
  
  static Map<String, String> authHeaders(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
  
  // ==================== TIMEOUTS ====================
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static foodsByRestaurantEndpoint(String restaurantId) {}
}