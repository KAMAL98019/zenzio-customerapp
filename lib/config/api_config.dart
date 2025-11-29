class ApiConfig {
  // Base URL
  // static const String baseUrl = 'https://backend.zenzio.in';
  // static const String baseUrl = 'https://erica-transthoracic-envyingly.ngrok-free.dev';
  // static const String baseUrl = 'http://72.61.172.167:3000';
  static const String baseUrl = 'https://api.zenzio.in';
  static const String apiVersion = '/api';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // ✅ Use your actual values from /clients/generate
  // static const clientId = 'b8da45ba-2a7a-488b-9764-60016ed964a5';
  static const clientId = '0fb4e7a0-8ca8-46a3-8ffe-0f4a078bb811';
  static const clientSecret = '';

  // ==================== NEW AUTH ENDPOINTS ==================== 
  static const String signupEndpoint = "/users/auth/signup/email";
  static const String loginEndpoint = "/users/auth/login/email";
  static const String loginWithOtpEndpoint = "/users/auth/login/otp"; 
  static const String firebaseSendVerificationEndpoint ="/firebase/send-verification";
  static const String userProfileEndpoint = '/users/me';
  static const String otpSendEndpoint = '/otp/send';
  static const String otpVerifyEndpoint = '/otp/verify';
  static const String refreshAuth = "/users/refresh-auth";
  static const String logoutEndpoint = '$apiVersion/auth/logout';

  // ==================== Home ENDPOINTS ====================
  static const String nearestRestaurantsEndpoint = "/restaurants/nearest";
  // static const String restaurantsEndpoint = '/restaurants';
  static const String getRestaurantById = "/restaurants/";
  // ==================== Menu ENDPOINTS ====================
  static const String foodItemsEndpoint = '/restaurant-menu/nearest';

  // ==================== CART ENDPOINTS ====================
  static const String cartEndpoint ='/cart'; // Get full cart for logged-in user
  static const String addToCartEndpoint = '/cart/add';
  static String restaurantItemsEndpoint(String restaurantUid) {
    return "/cart/restaurant/$restaurantUid/items";
  }
  static const String updateCartQtyEndpoint = '/cart/item';
  static const String removeCartItemEndpoint = '/cart/item';
  static const String clearRestCartEndpoint ='/cart/group'; // Clear all items from a specific restaurant group
  static const String clearCartEndpoint ='/cart/clear'; // Clear the complete cart
   static String getCartGroup(String restaurantUid) =>
      "/cart/group/$restaurantUid";
  //  static const String cartTransaction = "/cart-transactions";
   static const String cartTransaction = "/cart/payment-mode";
  static const String createOrder = "/cart-transactions";


  // ==================== PAYMENT ENDPOINTS ====================
  // static const String createRazorpayOrderEndpoint = "/payments/create-order";\
  static const String verifyPaymentEndpoint = "/payments/verify";
  // static const String verifyPaymentEndpoint = "/payments/auto-capture";

  // ==================== RATINGS ENDPOINTS ====================
  static const String customerRestaurantRating = "/rating/cust-restaurant";
  static const String customerFleetRating = "/rating/fleet-cust";
  static const String customerAppRating = "/rating/cus-app";

// -------- DELIVERY LOCATION ENDPOINT --------
  static const String deliveryLocation = "/delivery-location";


static String getRestaurantMenu(String restaurantUid) {
    return "/restaurant-menu/by-restaurant?restaurant_uid=$restaurantUid";
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);






  // ==================== AUTH OLD ENDPOINTS ====================
  // static const String loginEndpoint = '$apiVersion/users/auth/login';
  // static const String signupEndpoint = '$apiVersion/users';
  // static const String forgotPasswordEndpoint =
  //     '$apiVersion/users/auth/forgot-password/send-otp';
  // static const String resetPasswordEndpoint =
  //     '$apiVersion/users/auth/forgot-password/verify-otp';
  // static const String resetPasswordEndpoint = '$apiVersion/users/auth/forgot-password/verify-otp';
  // static const String logoutEndpoint = '$apiVersion/auth/logout';
  // static const String foodItemsEndpoint = '$baseUrl/food-items';

  // ==================== USER ENDPOINTS ====================
  // static const String usersEndpoint = '$apiVersion/users';
  // static const String userProfileEndpoint = '$apiVersion/users/me';
  // static const String updateProfileEndpoint = '$apiVersion/users/{userId}';

  // ==================== RESTAURANT ENDPOINTS ====================
  // static const String restaurantsEndpoint = '$apiVersion/restaurants';
  // static String restaurantDetailEndpoint(String id) =>'$apiVersion/restaurants/$id';
  // static String restaurantMenuEndpoint(String id) =>'$apiVersion/restaurants/$id/menu';

  // ==================== ORDER ENDPOINTS ====================
  // static const String ordersEndpoint = '$apiVersion/orders';
  // static String orderDetailEndpoint(String id) => '$apiVersion/orders/$id';
  // static String orderTrackingEndpoint(String id) =>
  //     '$apiVersion/orders/$id/tracking';

  // ==================== BOOKING ENDPOINTS ====================
  // static const String bookingsEndpoint = '$apiVersion/bookings';
  // static String bookingDetailEndpoint(String id) => '$apiVersion/bookings/$id';

  // ==================== ADDRESS ENDPOINTS ====================
  // static const String addressesEndpoint = '$apiVersion/addresses';
  // static String addressDetailEndpoint(String id) => '$apiVersion/addresses/$id';
  // ==================== CART ENDPOINTS ====================
  // static const String cartEndpoint = '$apiBaseUrl/cart';
  // static const String addToCartEndpoint = '$apiBaseUrl/cart/items';
  // static const String updateCartEndpoint = '$apiBaseUrl/carts/update';
  // static const String removeFromCartEndpoint = '$apiBaseUrl/carts/remove';
  // static const String clearCartEndpoint = '$apiBaseUrl/carts/clear';

  // ==================== PAYMENT ENDPOINTS ====================
  // static const String paymentMethodsEndpoint = '$apiVersion/payment-methods';
  // static const String processPaymentEndpoint = '$apiVersion/payments/process';

  // ==================== COUPON ENDPOINTS ====================
  // static const String couponsEndpoint = '$apiVersion/coupons';
  // static const String applyCouponEndpoint = '$apiVersion/coupons/apply';

  // ==================== NOTIFICATION ENDPOINTS ====================
  // static const String notificationsEndpoint = '$apiVersion/notifications';
  // static String markNotificationReadEndpoint(String id) =>
  //     '$apiVersion/notifications/$id/read';
  
}


class RazorpayConfig {
   // For Testing (Sandbox/Test Mode)
  static const String testKeyId = 'rzp_test_RhCBzg8fXhO9GQ';
  
  // For Production (Live Mode)
  static const String liveKeyId = ''; 
  
  // Environment flag
  static const bool isProduction = false; // Set to true for production
  
  static String get currentKeyId {
    return isProduction ? liveKeyId : testKeyId;
  }
}
