import 'package:zenzio_customer/services/api_service.dart';
import '../config/api_config.dart';

class CartTransactionService {
  final ApiService _api = ApiService();

  // ============================
  // CREATE CART TRANSACTION
  // ============================
  Future<Map<String, dynamic>> createCartTransaction({
    required String cartGroupUid,
    required String mode, // 'cod' or 'online'
    String? description,
  }) async {
    final body = {
      "cart_group_uid": cartGroupUid,
      "mode": mode,
      "description": description ?? "Transaction created",
    };

    print("🛒 Creating Cart Transaction => $body");

    try {
      final response = await _api.post(
        ApiConfig.cartTransaction,
        body: body,
        requiresAuth: true,
      );

      print("🛒 Cart Transaction Response => $response");

      if (response["data"] == null) {
        throw Exception("Failed to create cart transaction");
      }

      return response["data"];
    } catch (e) {
      print("❌ Cart Transaction Failed: $e");
      rethrow;
    }
  }

  // ============================
  // GET TRANSACTION DETAILS
  // ============================
  Future<Map<String, dynamic>> getTransactionDetails(String transactionId) async {
    try {
      final response = await _api.get(
        "${ApiConfig.cartTransaction}/$transactionId",
        requiresAuth: true,
      );

      print("📋 Transaction Details => $response");

      return response["data"] ?? {};
    } catch (e) {
      print("❌ Failed to get transaction details: $e");
      rethrow;
    }
  }
}