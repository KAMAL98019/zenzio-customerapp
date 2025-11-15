class ApiConfig {
  // Base URL
  // static const String baseUrl = 'https://backend.zenzio.in';
  static const String baseUrl = 'https://erica-transthoracic-envyingly.ngrok-free.dev';
  static const String apiVersion = '/api';
  // Full API Base
  static const String apiBaseUrl = '$baseUrl$apiVersion';
  
  // ✅ Use your actual values from /clients/generate
  // static const clientId = 'b8da45ba-2a7a-488b-9764-60016ed964a5';
  static const clientId = '0fb4e7a0-8ca8-46a3-8ffe-0f4a078bb811';
  static const clientSecret = '';


  // ==================== NEW AUTH ENDPOINTS ====================
  static const String signupEndpoint = "/users/auth/signup/email";
  static const String loginEndpoint = "/users/auth/login/email";
  static const String firebaseSendVerificationEndpoint = "/firebase/send-verification";
  static const String userProfileEndpoint = '/users/me';
  static const String otpSendEndpoint = '/otp/send';
  static const String otpVerifyEndpoint = '/otp/verify';
  
  static const String foodItemsEndpoint = '$baseUrl/restaurant-menu';


  // ==================== AUTH OLD ENDPOINTS ====================
  // static const String loginEndpoint = '$apiVersion/users/auth/login';
  // static const String signupEndpoint = '$apiVersion/users';
  
  static const String forgotPasswordEndpoint = '$apiVersion/users/auth/forgot-password/send-otp';
  static const String resetPasswordEndpoint = '$apiVersion/users/auth/forgot-password/verify-otp';
  // static const String resetPasswordEndpoint = '$apiVersion/users/auth/forgot-password/verify-otp';
  static const String logoutEndpoint = '$apiVersion/auth/logout';
  
  // static const String foodItemsEndpoint = '$baseUrl/food-items';

  // ==================== USER ENDPOINTS ====================
  static const String usersEndpoint = '$apiVersion/users';
  // static const String userProfileEndpoint = '$apiVersion/users/me';
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
static const String addToCartEndpoint = '$apiBaseUrl/cart/items';
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