import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutScreen extends StatefulWidget {
  final String userId;
  final String cartId;
  final double total;
  final double totalAmount; // ✅ add this
  final String restaurantId;

  const CheckoutScreen({
    super.key,
    required this.userId,
    required this.cartId,
    required this.total,
    required this.totalAmount, // ✅ add this
    required this.restaurantId, required razorpayOrderId, required currency, required amount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}


class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'card';
  List<Map<String, dynamic>> _cartItems = [];
  bool _loading = true;
  double _deliveryFee = 0;
  double _taxes = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    try {
      final url = Uri.parse(
          'https://your-backend.com/api/cart/${widget.cartId}?userId=${widget.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _cartItems = List<Map<String, dynamic>>.from(data['items']);
          _deliveryFee = data['deliveryFee']?.toDouble() ?? 0;
          _taxes = data['taxes']?.toDouble() ?? 0;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _placeOrder() async {
    try {
      final url = Uri.parse('https://your-backend.com/api/orders');
      final body = {
        'userId': widget.userId,
        'cartId': widget.cartId,
        'restaurantId': widget.restaurantId,
        'paymentMethod': _selectedPayment,
        'deliveryAddress': '123 Main Street, Apt 4B, New York, NY 10001',
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Order placed successfully
        Navigator.pushNamed(context, '/order-tracking');
      } else {
        final res = json.decode(response.body);
        _showError(res['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      print('Error placing order: $e');
      _showError('Something went wrong. Try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double itemTotal = _cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));

    double grandTotal = itemTotal + _deliveryFee + _taxes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Section
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
            // Payment Options Section
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
                      'card', 'Credit/Debit Card', '••••4582', Icons.credit_card),
                  _buildPaymentOption(
                      'upi', 'UPI', 'username@upibank', Icons.account_balance),
                  _buildPaymentOption(
                      'wallet', 'Wallet', '₹25.50 available', Icons.account_balance_wallet),
                  _buildPaymentOption(
                      'netbanking', 'Net Banking', null, Icons.account_balance),
                  _buildPaymentOption('cod', 'Cash on Delivery', null, Icons.money),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
            // Order Summary Section
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
                  for (var item in _cartItems)
                    _buildOrderItem(item['name'], item['quantity'], item['price']),
                  const Divider(height: 32),
                  _buildBillRow('Item Total', '₹$itemTotal'),
                  _buildBillRow('Delivery Fee', '₹$_deliveryFee'),
                  _buildBillRow('Taxes & Charges', '₹$_taxes'),
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
                        '₹$grandTotal',
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
      bottomNavigationBar: Container(
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
      String value, String title, String? subtitle, IconData icon) {
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


// import 'dart:convert';
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
