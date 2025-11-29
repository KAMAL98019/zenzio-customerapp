import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zenzio/config/api_config.dart';
import 'package:zenzio/screens/cart/cart_screen.dart';
import 'package:zenzio/services/CartTransactionService.dart';
import 'package:zenzio/services/PaymentService.dart';


class CheckoutScreen extends StatefulWidget {
  final String cartGroupUid;
  final String restaurantId;
  final List<CartItem> cartItems;
  final double itemTotal;
  final double deliveryFee;
  final double taxes;
  final double grandTotal;

  const CheckoutScreen({
    super.key,
    required this.cartGroupUid,
    required this.restaurantId,
    required this.cartItems,
    required this.itemTotal,
    required this.deliveryFee,
    required this.taxes,
    required this.grandTotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'card';
  bool _isProcessing = false;
  late Razorpay _razorpay;
  final CartTransactionService _transactionService = CartTransactionService();
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("✅ Payment Success: ${response.paymentId}");
    
    setState(() => _isProcessing = true);

    try {
      // Verify payment with backend
      await _paymentService.verifyPayment(
        // orderId: response.orderId ?? '',
        // paymentId: response.paymentId ?? '',
        // signature: response.signature ?? '',
         paymentId: response.paymentId!,
      amountInPaise: (widget.grandTotal * 100).toInt()
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Payment successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to order tracking
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/order-tracking',
        (route) => false,
      );
    } catch (e) {
      print("❌ Payment verification failed: $e");
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Payment verification failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ Payment Error: ${response.code} - ${response.message}");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("📱 External Wallet: ${response.walletName}");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📱 External wallet selected: ${response.walletName}'),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      if (_selectedPayment == 'cod') {
        // ✅ Cash on Delivery flow
        await _handleCODPayment();
      } else {
        // ✅ Online payment (Razorpay) flow
        await _handleOnlinePayment();
      }
    } catch (e) {
      print("❌ Order placement failed: $e");
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to place order: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCODPayment() async {
    print("💵 Processing COD payment...");

    // Create cart transaction with COD mode
    final transaction = await _transactionService.createCartTransaction(
      cartGroupUid: widget.cartGroupUid,
      mode: 'cod',
      // description: 'Cash on Delivery order',
    );

    print("✅ COD Transaction created: $transaction");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Order placed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to order tracking
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/order-tracking',
      (route) => false,
    );
  }

  Future<void> _handleOnlinePayment() async {
    print("💳 Processing online payment...");

    // Step 1: Create cart transaction with online mode
    final transaction = await _transactionService.createCartTransaction(
      cartGroupUid: widget.cartGroupUid,
      mode: 'online',
      // description: 'Online payment via Razorpay',
    );

    print("✅ Transaction created: $transaction");

    // Step 2: Create Razorpay order
    final razorpayOrder = await _paymentService.createRazorpayOrder(
      amount: widget.grandTotal,
      restaurantUid: widget.restaurantId,
      groupUid: widget.cartGroupUid,
    );

    print("✅ Razorpay order created: $razorpayOrder");

    // Step 3: Open Razorpay checkout
    var options = {
      'key': RazorpayConfig.currentKeyId, // Get from backend response
      'amount': (widget.grandTotal * 100).toInt(), // Amount in paise
      'name': 'Zenzio',
      'order_id': razorpayOrder['order_id'],
      'description': 'Payment for Order',
      'prefill': {
        'contact': '1234567890', // Get from user profile
        'email': 'user@example.com' // Get from user profile
      },
      'theme': {
        'color': '#E53935'
      }
    };

    setState(() => _isProcessing = false);

    try {
      _razorpay.open(options);
    } catch (e) {
      print("❌ Error opening Razorpay: $e");
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error opening payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE53935)),
                  SizedBox(height: 16),
                  Text(
                    'Processing your order...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/saved-addresses');
                              },
                              child: const Text(
                                'Change Address',
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '123 Main Street, Apt 4B, New York, NY 10001',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.map,
                              size: 50,
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Options',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentOption(
                          'card',
                          'Credit/Debit Card',
                          'Pay securely via Razorpay',
                          Icons.credit_card,
                        ),
                        _buildPaymentOption(
                          'upi',
                          'UPI',
                          'Pay via UPI apps',
                          Icons.account_balance,
                        ),
                        _buildPaymentOption(
                          'netbanking',
                          'Net Banking',
                          'Pay via Net Banking',
                          Icons.account_balance,
                        ),
                        _buildPaymentOption(
                          'cod',
                          'Cash on Delivery',
                          'Pay when you receive',
                          Icons.money,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Display real cart items
                        ...widget.cartItems.map((item) => _buildOrderItem(
                              item.name,
                              item.quantity,
                              item.price * item.quantity,
                            )),
                        const Divider(height: 32),
                        _buildBillRow('Item Total', '₹${widget.itemTotal.toStringAsFixed(2)}'),
                        _buildBillRow('Delivery Fee', '₹${widget.deliveryFee.toStringAsFixed(2)}'),
                        _buildBillRow('Taxes & Charges', '₹${widget.taxes.toStringAsFixed(2)}'),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE53935),
                              ),
                            ),
                            Text(
                              '₹${widget.grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _isProcessing
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String? subtitle,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPayment == value
                ? const Color(0xFFE53935)
                : const Color(0xFFE0E0E0),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _selectedPayment == value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _selectedPayment == value
                  ? const Color(0xFFE53935)
                  : const Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: const Color(0xFF757575)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(String name, int quantity, int price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fastfood,
              color: Color(0xFFE0E0E0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$name × $quantity',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          Text(
            '₹$price',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }
}

// main import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../myOrder/order_tracking_screen.dart';

// class CheckoutScreen extends StatefulWidget {
//   final String userId;
//   final String cartId;
//   final double total;

//   const CheckoutScreen({
//     super.key,
//     required this.userId,
//     required this.cartId,
//     required this.total, required double totalAmount,
//   });

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   bool _isPlacingOrder = false;
//   String _paymentMethod = 'Online Payment'; // default selection

//   Future<void> _placeOrder() async {
//     setState(() {
//       _isPlacingOrder = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('https://backend.zenzio.in/api/orders/checkout'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "userId": widget.userId,
//           "cartId": widget.cartId,
//           "paymentMethod": _paymentMethod,
//           "total": widget.total,
//         }),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ Order placed successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OrderTrackingScreen(
//               orderId: data['order']['_id'] ?? '',
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data['message'] ?? '⚠️ Failed to place order'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Error placing order: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('⚠️ Something went wrong. Try again later.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isPlacingOrder = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final addressController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Checkout',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             const Text(
//               'Delivery Address',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: addressController,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: 'Enter your delivery address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 focusedBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(color: Color(0xFFE53935)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Payment Method',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildPaymentOption('Online Payment'),
//             _buildPaymentOption('Cash on Delivery'),
//             const SizedBox(height: 24),
//             const Text(
//               'Order Summary',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildSummaryRow('Subtotal', '₹${widget.total.toStringAsFixed(2)}'),
//             _buildSummaryRow('Delivery Fee', '₹50.00'),
//             _buildSummaryRow('Taxes', '₹${(widget.total * 0.05).toStringAsFixed(2)}'),
//             const Divider(height: 24),
//             _buildSummaryRow(
//               'Grand Total',
//               '₹${(widget.total + 50 + widget.total * 0.05).toStringAsFixed(2)}',
//               isBold: true,
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         height: 80,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: ElevatedButton(
//           onPressed: _isPlacingOrder ? null : _placeOrder,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFFE53935),
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 16),
//           ),
//           child: _isPlacingOrder
//               ? const CircularProgressIndicator(color: Colors.white)
//               : const Text(
//                   'Place Order',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentOption(String method) {
//     return InkWell(
//       onTap: () => setState(() => _paymentMethod = method),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: _paymentMethod == method
//                 ? const Color(0xFFE53935)
//                 : const Color(0xFFE0E0E0),
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               _paymentMethod == method
//                   ? Icons.radio_button_checked
//                   : Icons.radio_button_off,
//               color: const Color(0xFFE53935),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               method,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryRow(String title, String value, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[700],
//               fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               color: isBold ? const Color(0xFFE53935) : Colors.black,
//               fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key, required String userId, required double total, required String cartId, required totalAmount, required restaurantId});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   String _selectedPayment = 'card';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Checkout',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Delivery Address',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2D2D2D),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pushNamed(context, '/saved-addresses');
//                         },
//                         child: const Text(
//                           'Change Address',
//                           style: TextStyle(
//                             color: Color(0xFFE53935),
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     '123 Main Street, Apt 4B, New York, NY 10001',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF757575),
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     height: 120,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF5F5F5),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Center(
//                       child: Icon(
//                         Icons.map,
//                         size: 50,
//                         color: Color(0xFFE0E0E0),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Payment Options',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildPaymentOption(
//                     'card',
//                     'Credit/Debit Card',
//                     '••••4582',
//                     Icons.credit_card,
//                   ),
//                   _buildPaymentOption(
//                     'upi',
//                     'UPI',
//                     'username@upibank',
//                     Icons.account_balance,
//                   ),
//                   _buildPaymentOption(
//                     'wallet',
//                     'Wallet',
//                     '₹25.50 available',
//                     Icons.account_balance_wallet,
//                   ),
//                   _buildPaymentOption(
//                     'netbanking',
//                     'Net Banking',
//                     null,
//                     Icons.account_balance,
//                   ),
//                   _buildPaymentOption(
//                     'cod',
//                     'Cash on Delivery',
//                     null,
//                     Icons.money,
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Order Summary',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildOrderItem('Beef Burger', 1, 129),
//                   _buildOrderItem('Cheese Fries', 2, 599),
//                   _buildOrderItem('Chocolate Milkshake', 1, 450),
//                   const Divider(height: 32),
//                   _buildBillRow('Item Total', '₹129'),
//                   _buildBillRow('Delivery Fee', '₹599'),
//                   _buildBillRow('Taxes & Charges', '₹450'),
//                   const Divider(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Grand Total',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFFE53935),
//                         ),
//                       ),
//                       const Text(
//                         '₹3571',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFFE53935),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: SizedBox(
//           height: 56,
//           child: ElevatedButton(
//             onPressed: () {
//               Navigator.pushNamed(context, '/order-tracking');
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53935),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text(
//               'Place Order',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentOption(
//     String value,
//     String title,
//     String? subtitle,
//     IconData icon,
//   ) {
//     return GestureDetector(
//       onTap: () => setState(() => _selectedPayment = value),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: _selectedPayment == value
//                 ? const Color(0xFFE53935)
//                 : const Color(0xFFE0E0E0),
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               _selectedPayment == value
//                   ? Icons.radio_button_checked
//                   : Icons.radio_button_unchecked,
//               color: _selectedPayment == value
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFF9E9E9E),
//             ),
//             const SizedBox(width: 12),
//             Icon(icon, color: const Color(0xFF757575)),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   if (subtitle != null) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF9E9E9E),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderItem(String name, int quantity, int price) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5F5),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(
//               Icons.fastfood,
//               color: Color(0xFFE0E0E0),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               '$name × $quantity',
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//           ),
//           Text(
//             '₹$price',
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF2D2D2D),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBillRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Color(0xFF757575),
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF2D2D2D),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
