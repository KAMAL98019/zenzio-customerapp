// import 'package:zenzio_customer/services/api_service.dart';
// import '../config/api_config.dart';

// class PaymentService {
//   final ApiService _api = ApiService();

//   // ============================
//   // CREATE RAZORPAY ORDER
//   // ============================
//   Future<Map<String, dynamic>> createRazorpayOrder({
//     required double amount,
//     required String restaurantUid,
//     required String groupUid,
//   }) async {
//     final body = {
//       "amount": amount,
//       "restaurantUid": restaurantUid,
//       "groupUid": groupUid,
//     };

//     print("💳 Creating Razorpay Order => $body");

//     try {
//       final response = await _api.post(
//         ApiConfig.createRazorpayOrderEndpoint,
//         body: body,
//         requiresAuth: true,
//       );

//       print("💳 Razorpay Order Response => $response");

//       if (response["data"] == null) {
//         throw Exception("Failed to create Razorpay order");
//       }

//       return response["data"];
//     } catch (e) {
//       print("❌ Razorpay Order Creation Failed: $e");
//       rethrow;
//     }
//   }

//   // ============================
//   // VERIFY PAYMENT
//   // ============================
//   Future<Map<String, dynamic>> verifyPayment({
//     required String orderId,
//     required String paymentId,
//     required String signature,
//   }) async {
//     final body = {
//       "razorpay_order_id": orderId,
//       "razorpay_payment_id": paymentId,
//       "razorpay_signature": signature,
//     };

//     print("✅ Verifying Payment => $body");

//     try {
//       final response = await _api.post(
//         ApiConfig.verifyPaymentEndpoint,
//         body: body,
//         requiresAuth: true,
//       );

//       print("✅ Payment Verification Response => $response");

//       return response["data"] ?? {};
//     } catch (e) {
//       print("❌ Payment Verification Failed: $e");
//       rethrow;
//     }
//   }
// }

import 'package:zenzio/services/api_service.dart';
import '../config/api_config.dart';

class PaymentService {
  final ApiService _api = ApiService();

  // CREATE RAZORPAY ORDER
  // ============================
  Future<Map<String, dynamic>> createRazorpayOrder({
    required double amount,
    required String restaurantUid,
    required String groupUid,
  }) async {
    final body = {
      "amount": amount,
      "restaurantUid": restaurantUid,
      "groupUid": groupUid,
    };

    print("💳 Creating Razorpay Order => $body");

    try {
      final response = await _api.post(
        ApiConfig.createRazorpayOrderEndpoint,
        body: body,
        requiresAuth: true,
      );

      print("💳 Razorpay Order Response => $response");

      // ✅ Handle different response formats
      Map<String, dynamic> orderData;

      if (response is Map<String, dynamic>) {
        // Check if response has 'data' wrapper
        if (response.containsKey("data")) {
          orderData = response["data"] as Map<String, dynamic>;
        }
        // Check if response has Razorpay order fields directly
        else if (response.containsKey("id") && response.containsKey("amount")) {
          orderData = response;
        } else {
          throw Exception(
            "Invalid response format from Razorpay order creation",
          );
        }

        // Ensure we have the required fields
        if (!orderData.containsKey("id")) {
          throw Exception("Razorpay order ID not found in response");
        }

        return orderData;
      } else {
        throw Exception("Invalid response type from Razorpay order creation");
      }
    } catch (e) {
      print("❌ Razorpay Order Creation Failed: $e");
      rethrow;
    }
  }

  // VERIFY PAYMENT
  // ============================
  Future<Map<String, dynamic>> verifyPayment({
    // required String orderId,
    // required String paymentId,
    // required String signature,
    required String paymentId,
    required int amountInPaise,
  }) async {
    final body = {
      // "razorpay_order_id": orderId,
      // "razorpay_payment_id": paymentId,
      // "razorpay_signature": signature  ,
      "razorpay_paymentId": paymentId,
      "razorpay_amountInPaise": amountInPaise,
    };

    print("✅ Verifying Payment => $body");

    try {
      final response = await _api.post(
        ApiConfig.verifyPaymentEndpoint,
        body: body,
        requiresAuth: true,
      );

      print("✅ Payment Verification Response => $response");

      return response["data"] ?? {};
    } catch (e) {
      print("❌ Payment Verification Failed: $e");
      rethrow;
    }
  }
}
