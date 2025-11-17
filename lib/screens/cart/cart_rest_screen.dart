import 'package:flutter/material.dart';
import 'package:zenzio_customer/services/api_service.dart';
import 'package:zenzio_customer/services/token_service.dart';
import 'package:zenzio_customer/config/api_config.dart';
import 'dart:convert';

class CartRestScreen extends StatefulWidget {
  const CartRestScreen({super.key});

  @override
  State<CartRestScreen> createState() => _CartRestScreenState();
}

class _CartRestScreenState extends State<CartRestScreen> {
  bool _isLoading = true;
  List<RestaurantCart> _restaurantCarts = [];
  final ApiService _api = ApiService();

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

      if (response["success"] != true || response["carts"] == null) {
        setState(() {
          _restaurantCarts = [];
          _isLoading = false;
        });
        return;
      }

      List<RestaurantCart> carts = [];

      for (var cart in response["carts"]) {
        final rest = cart["restaurant"];
        final items = cart["items"];

        double grandTotal = 0;
        for (var item in items) {
          double price = double.tryParse(item["unitPrice"].toString()) ?? 0;
          double addonPrice = 0;

          for (var addon in item["selectedAddOns"]) {
            addonPrice += double.tryParse(addon["price"].toString()) ?? 0;
          }

          grandTotal += (price + addonPrice) * item["quantity"];
        }

        carts.add(
          RestaurantCart(
            restaurantName: rest["rest_name"],
            description: rest["rest_address"],
            totalItems: items.length,
            grandTotal: grandTotal,
            restId: rest["id"].toString(),
          ),
        );
      }

      setState(() {
        _restaurantCarts = carts;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Cart Error: $e");
      setState(() {
        _isLoading = false;
        _restaurantCarts = [];
      });
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



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class CartRestScreen extends StatefulWidget {
//   const CartRestScreen({super.key});

//   @override
//   State<CartRestScreen> createState() => _CartRestScreenState();
// }

// class _CartRestScreenState extends State<CartRestScreen> {
//   bool _isLoading = true;
//   RestaurantCart? _restaurantCart; // only one restaurant in your active cart
//   String? _userId;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCartData();
//   }

//   Future<void> _fetchCartData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _userId = prefs.getString('user_id');

//       if (_userId == null) {
//         throw Exception('User ID not found in SharedPreferences');
//       }

//       final url = Uri.parse(
//           'https://backend.zenzio.in/api/cart/active?userId=$_userId');
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data['success'] == true && data['cart'] != null) {
//           final cart = data['cart'];
//           final restaurant = cart['items'][0]['food']['restaurant'];
//           final totalItems = cart['items'].length;

//           double grandTotal = 0;
//           for (var item in cart['items']) {
//             double unitPrice = double.tryParse(item['unitPrice'].toString()) ?? 0;
//             double addOns = 0;
//             for (var addOn in item['selectedAddOns']) {
//               addOns += double.tryParse(addOn['price'].toString()) ?? 0;
//             }
//             grandTotal += (unitPrice + addOns) * (item['quantity'] ?? 1);
//           }

//           setState(() {
//             _restaurantCart = RestaurantCart(
//               restaurantName: restaurant['rest_name'],
//               description: restaurant['rest_address'],
//               totalItems: totalItems,
//               grandTotal: grandTotal,
//               restId: restaurant['id'],
//             );
//             _isLoading = false;
//           });
//         } else {
//           throw Exception('No active cart found');
//         }
//       } else {
//         throw Exception('Failed to load cart: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error fetching cart: $e');
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

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
//               ? const Center(child: Text('No active cart found'))
//               : Column(
//                   children: [
//                     Expanded(
//                       child: ListView(
//                         padding: const EdgeInsets.all(16),
//                         children: [
//                           _buildRestaurantCard(_restaurantCart!),
//                         ],
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
//                           onPressed: () {
//                             if (_restaurantCart != null) {
//                               Navigator.pushNamed(
//                                 context,
//                                 '/cart',
//                                 arguments: _restaurantCart!.restId, // ✅ send rest_id
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFE53935),
//                             foregroundColor: Colors.white,
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
//         Navigator.pushNamed(
//           context,
//           '/cart',
//           arguments: cart.restId, // ✅ send rest_id
//         );
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
//             Text(
//               cart.restaurantName,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 8),
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
//                 const Text('Total Items', style: TextStyle(fontSize: 14)),
//                 Text('${cart.totalItems}'),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Grand Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//                 Text('₹${cart.grandTotal.toStringAsFixed(2)}'),
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

//   RestaurantCart({
//     required this.restaurantName,
//     required this.description,
//     required this.totalItems,
//     required this.grandTotal,
//     required this.restId,
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