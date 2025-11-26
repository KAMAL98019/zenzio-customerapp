import 'package:flutter/material.dart';
import 'package:zenzio/services/api_service.dart';
import 'package:zenzio/services/token_service.dart';
import 'package:zenzio/services/cart_service.dart';
import 'package:zenzio/config/api_config.dart';

class CartRestScreen extends StatefulWidget {
  const CartRestScreen({super.key});

  @override
  State<CartRestScreen> createState() => _CartRestScreenState();
}

class _CartRestScreenState extends State<CartRestScreen> {
  bool _isLoading = true;
  List<RestaurantCart> _restaurantCarts = [];
  final ApiService _api = ApiService();
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _fetchFullCart();
  }

  // ========================= FETCH FULL CART =========================
  Future<void> _fetchFullCart() async {
    try {
      final userId = await TokenService().getUserId();
      if (userId == null) throw Exception("User not logged in");

      final endpoint = "${ApiConfig.cartEndpoint}?userId=$userId";

      final response = await _api.get(endpoint, requiresAuth: true);

      print("🛒 FULL CART RESPONSE => $response");

      if (response["status"] != "success" || response["data"]?["cart"] == null) {
        setState(() {
          _restaurantCarts = [];
          _isLoading = false;
        });
        return;
      }

      final cartData = response["data"]["cart"];
      final groups = cartData["groups"] as List<dynamic>? ?? [];

      List<RestaurantCart> carts = [];

      for (var group in groups) {
        final restId = group["restaurant_uid"] ?? "";
        final items = group["items"] as List<dynamic>? ?? [];
        double subtotal = 0;

        for (var item in items) {
          final price = double.tryParse(item["price"].toString()) ?? 0;
          final qty = int.tryParse(item["qty"].toString()) ?? 1;
          subtotal += price * qty;
        }

        carts.add(
          RestaurantCart(
            // restaurantName: restId,
            restaurantName: group["restaurant_name"] ?? "Unknown Restaurant",
            description: "",
            totalItems: items.length,
            grandTotal: subtotal.toDouble(),
            restId: restId,
          ),
        );
      }

      setState(() {
        _restaurantCarts = carts;
        _isLoading = false;
      });

    } catch (e) {
      print("❌ Cart Error: $e");
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _restaurantCarts = [];
      });
    }
  }

  // ========================= CLEAR CART DIALOG =========================
  Future<void> _showClearCartDialog(String restaurantId, String restaurantName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Clear Cart?",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: Text(
          "Are you sure you want to clear all items from this cart?",
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _clearRestaurantCart(restaurantId);
    }
  }

  // ========================= CLEAR RESTAURANT CART =========================
  Future<void> _clearRestaurantCart(String restaurantId) async {
    try {
      setState(() => _isLoading = true);
      await _cartService.clearRestaurantCart(restaurantId);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cart cleared successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await _fetchFullCart();
    } catch (e) {
      print("❌ Clear Cart Error: $e");
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to clear cart: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      
      setState(() => _isLoading = false);
    }
  }

  // ========================= UI =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _restaurantCarts.isEmpty
          ? const Center(child: Text("🛒 No carts found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _restaurantCarts.length,
              itemBuilder: (context, index) =>
                  _buildRestaurantCard(_restaurantCarts[index]),
            ),
    );
  }

  Widget _buildRestaurantCard(RestaurantCart cart) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/cart", arguments: cart.restId);
        print("🛒 FULL CART RESPONSE => ${cart.restId}");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cart.restaurantName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(cart.description, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text("Total Items"), Text('${cart.totalItems}')],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '₹${cart.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Clear Cart Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showClearCartDialog(cart.restId, cart.restaurantName),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  "Clear Cart",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================= MODEL =========================
class RestaurantCart {
  final String restaurantName;
  final String description;
  final int totalItems;
  final double grandTotal;
  final String restId;

  RestaurantCart({
    required this.restaurantName,
    required this.description,
    required this.totalItems,
    required this.grandTotal,
    required this.restId,
  });
}

// import 'package:flutter/material.dart';
// import 'package:zenzio_customer/services/api_service.dart';
// import 'package:zenzio_customer/services/token_service.dart';
// import 'package:zenzio_customer/config/api_config.dart';
// import 'dart:convert';

// class CartRestScreen extends StatefulWidget {
//   const CartRestScreen({super.key});

//   @override
//   State<CartRestScreen> createState() => _CartRestScreenState();
// }

// class _CartRestScreenState extends State<CartRestScreen> {
//   bool _isLoading = true;
//   List<RestaurantCart> _restaurantCarts = [];
//   final ApiService _api = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     _fetchFullCart();
//   }

//   // ========================= FETCH FULL CART =========================
//   Future<void> _fetchFullCart() async {
//     try {
//       final userId = await TokenService().getUserId();
//       if (userId == null) throw Exception("User not logged in");

//       final endpoint = "${ApiConfig.cartEndpoint}?userId=$userId";

//       final response = await _api.get(endpoint, requiresAuth: true);

//       print("🛒 FULL CART RESPONSE => $response");

//     if (response["status"] != "success" || response["data"]?["cart"] == null) {
//   setState(() {
//     _restaurantCarts = [];
//     _isLoading = false;
//   });
//   return;
// }

// final cartData = response["data"]["cart"];
// final groups = cartData["groups"] as List<dynamic>? ?? [];

// List<RestaurantCart> carts = [];

// for (var group in groups) {
//   final restId = group["restaurant_uid"] ?? "";
//   final items = group["items"] as List<dynamic>? ?? [];
//   double subtotal = 0;

//   for (var item in items) {
//  final price = double.tryParse(item["price"].toString()) ?? 0;
//     final qty = int.tryParse(item["qty"].toString()) ?? 1;

//     subtotal += price * qty;  }

//   carts.add(
//     RestaurantCart(
//       restaurantName: restId, // Or fetch name if API returns
//       description: "",
//       totalItems: items.length,
//       grandTotal: subtotal.toDouble(),
//       restId: restId,
//     ),
//   );
// }

// setState(() {
//   _restaurantCarts = carts;
//   _isLoading = false;
// });

//     }catch (e) {
//   print("❌ Cart Error: $e");
//   if (!mounted) return;   // ⛔ Prevent setState after dispose

//   setState(() {
//     _isLoading = false;
//     _restaurantCarts = [];
//   });
// }
//   }

//   // ========================= UI =========================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "My Cart",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.red))
//           : _restaurantCarts.isEmpty
//           ? const Center(child: Text("🛒 No carts found"))
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: _restaurantCarts.length,
//               itemBuilder: (context, index) =>
//                   _buildRestaurantCard(_restaurantCarts[index]),
//             ),
//     );
//   }

//   Widget _buildRestaurantCard(RestaurantCart cart) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, "/cart", arguments: cart.restId);
//             print("🛒 FULL CART RESPONSE => ${cart.restId}");

//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 8,
//               color: Colors.black.withOpacity(0.05),
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               cart.restaurantName,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Text(cart.description, style: const TextStyle(fontSize: 13)),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [const Text("Total Items"), Text('${cart.totalItems}')],
//             ),
//             const SizedBox(height: 6),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Grand Total",
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 Text(
//                   '₹${cart.grandTotal.toStringAsFixed(2)}',
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ========================= MODEL =========================
// class RestaurantCart {
//   final String restaurantName;
//   final String description;
//   final int totalItems;
//   final double grandTotal;
//   final String restId;

//   RestaurantCart({
//     required this.restaurantName,
//     required this.description,
//     required this.totalItems,
//     required this.grandTotal,
//     required this.restId,
//   });
// }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:zenzio_customer/services/token_service.dart';

// class CartRestScreen extends StatefulWidget {
//   const CartRestScreen({super.key});

//   @override
//   State<CartRestScreen> createState() => _CartRestScreenState();
// }

// class _CartRestScreenState extends State<CartRestScreen> {
//   bool _isLoading = true;
//   RestaurantCart? _restaurantCart; 
//   String? _userId;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCartData();
//   }
// Future<void> _fetchCartData() async {
//   try {
//     // ✅ Get token and userId
//     final tokenService = TokenService();
//     final token = await tokenService.getToken();
//     final userId = await tokenService.getUserId(); // <-- Add this line

//     if (token == null || userId == null) throw Exception('User not logged in');

//     // ✅ Include userId in API call
//     final url = Uri.parse('https://backend.zenzio.in/api/cart/active?userId=$userId');
//     final response = await http.get(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);

//       if (data['success'] == true && data['cart'] != null) {
//         final cart = data['cart'];
//         final restaurant = cart['items'][0]['food']['restaurant'];
//         final totalItems = cart['items'].length;

//         double grandTotal = 0;
//         for (var item in cart['items']) {
//           double unitPrice = double.tryParse(item['unitPrice'].toString()) ?? 0;
//           double addOns = 0;
//           for (var addOn in item['selectedAddOns']) {
//             addOns += double.tryParse(addOn['price'].toString()) ?? 0;
//           }
//           grandTotal += (unitPrice + addOns) * (item['quantity'] ?? 1);
//         }

//         if (!mounted) return;
//         setState(() {
//           _restaurantCart = RestaurantCart(
//             restaurantName: restaurant['rest_name'],
//             description: restaurant['rest_address'],
//             totalItems: totalItems,
//             grandTotal: grandTotal,
//             restId: restaurant['id'],
//             isSelected: true,
//           );
//           _isLoading = false;
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _restaurantCart = null;
//           _isLoading = false;
//         });
//       }
//     } else {
//       throw Exception('Failed to load cart: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('❌ Error fetching cart: $e');
//     if (!mounted) return;
//     setState(() {
//       _isLoading = false;
//       _restaurantCart = null;
//     });
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'My Cart',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
//           : _restaurantCart == null
//               ? const Center(
//                   child: Text(
//                     '🛒 No active cart found',
//                     style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
//                   ),
//                 )
//               : Column(
//                   children: [
//                     Expanded(
//                       child: ListView(
//                         padding: const EdgeInsets.all(16),
//                         children: [_buildRestaurantCard(_restaurantCart!)],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, -2),
//                           ),
//                         ],
//                       ),
//                       child: SizedBox(
//                         width: double.infinity,
//                         height: 56,
//                         child: ElevatedButton(
//                           onPressed: _restaurantCart == null
//                               ? null
//                               : () {
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/cart',
//                                     arguments: _restaurantCart!.restId,
//                                   );
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFE53935),
//                             foregroundColor: Colors.white,
//                             disabledBackgroundColor: Colors.grey.shade300,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: const Text(
//                             'Proceed to Checkout',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }

//   Widget _buildRestaurantCard(RestaurantCart cart) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, '/cart', arguments: cart.restId);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: cart.isSelected
//                           ? const Color(0xFFE53935)
//                           : const Color(0xFFE0E0E0),
//                       width: 2,
//                     ),
//                   ),
//                   child: cart.isSelected
//                       ? Center(
//                           child: Container(
//                             width: 12,
//                             height: 12,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Color(0xFFE53935),
//                             ),
//                           ),
//                         )
//                       : null,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   cart.restaurantName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               cart.description,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: Color(0xFF9E9E9E),
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Total Item',
//                   style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
//                 ),
//                 Text(
//                   '${cart.totalItems}',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Grand Total',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 Text(
//                   '₹${cart.grandTotal.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RestaurantCart {
//   String restaurantName;
//   String description;
//   int totalItems;
//   double grandTotal;
//   String restId;
//   bool isSelected;

//   RestaurantCart({
//     required this.restaurantName,
//     required this.description,
//     required this.totalItems,
//     required this.grandTotal,
//     required this.restId,
//     this.isSelected = false,
//   });
// }


// import 'package:flutter/material.dart';

// class CartRestScreen extends StatefulWidget {
//   const CartRestScreen({super.key});

//   @override
//   State<CartRestScreen> createState() => _CartRestScreenState();
// }

// class _CartRestScreenState extends State<CartRestScreen> {
//   final List<RestaurantCart> _restaurantCarts = [
//     RestaurantCart(
//       restaurantName: 'Urban Bistro',
//       description: 'Modern European cuisine in a casual setting with panoramic city views',
//       totalItems: 5,
//       grandTotal: 35.71,
//       isSelected: false,
//     ),
//     RestaurantCart(
//       restaurantName: 'Seaside Grill',
//       description: 'Modern European cuisine in a casual setting with panoramic city views',
//       totalItems: 5,
//       grandTotal: 35.71,
//       isSelected: true,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'My Cart',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: _restaurantCarts.length,
//               itemBuilder: (context, index) {
//                 return _buildRestaurantCard(_restaurantCarts[index]);
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/cart');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   'Proceed to Checkout',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRestaurantCard(RestaurantCart cart) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, '/cart');
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: cart.isSelected
//                           ? const Color(0xFFE53935)
//                           : const Color(0xFFE0E0E0),
//                       width: 2,
//                     ),
//                   ),
//                   child: cart.isSelected
//                       ? Center(
//                           child: Container(
//                             width: 12,
//                             height: 12,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Color(0xFFE53935),
//                             ),
//                           ),
//                         )
//                       : null,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   cart.restaurantName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               cart.description,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: Color(0xFF9E9E9E),
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Total Item',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF757575),
//                   ),
//                 ),
//                 Text(
//                   '0${cart.totalItems}',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Grand Total',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 Text(
//                   '₹${cart.grandTotal.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RestaurantCart {
//   String restaurantName;
//   String description;
//   int totalItems;
//   double grandTotal;
//   bool isSelected;

//   RestaurantCart({
//     required this.restaurantName,
//     required this.description,
//     required this.totalItems,
//     required this.grandTotal,
//     required this.isSelected,
//   });
// }