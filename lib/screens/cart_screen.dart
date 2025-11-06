import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/restaurant_detail_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<CartItem> _cartItems = [];
  String _restaurantName = "Loading...";
  String? _restaurantId;
  String? _cartId;
  Map<String, dynamic>? _restaurantData;
  double _deliveryFee = 0;
  double _taxes = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  Future<void> _fetchCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) throw Exception("User ID not found");

      final url = Uri.parse(
        'https://backend.zenzio.in/api/cart/active?userId=$userId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['cart'] != null) {
          final cart = data['cart'];
          _cartId = cart['id'] ?? cart['_id'];
          final items = cart['items'] as List;

         final firstItem = cart['items'].isNotEmpty ? cart['items'][0] : null;
final restaurant = firstItem != null ? firstItem['food']['restaurant'] : null;

if (restaurant != null) {
  _restaurantName = restaurant['rest_name'] ?? 'Unknown Restaurant';
  _restaurantId = restaurant['_id'] ?? restaurant['id'] ?? '';
  debugPrint("🍽 Restaurant ID fetched: $_restaurantId");

  _restaurantData = restaurant;
} else {
  _restaurantName = 'Unknown Restaurant';
  _restaurantId = '';
}


          _cartItems = items.map((item) {
            final food = item['food'];
            double unitPrice =
                double.tryParse(item['unitPrice'].toString()) ?? 0;
            double addOnPrice = 0;
            if (item['selectedAddOns'] != null) {
              for (var addOn in item['selectedAddOns']) {
                addOnPrice += double.tryParse(addOn['price'].toString()) ?? 0;
              }
            }

            return CartItem(
              id: item['id'] ?? item['_id'],
              name: food['dishname'] ?? "Unknown Dish",
              price: (unitPrice + addOnPrice).toInt(),
              quantity: item['quantity'] ?? 1,
              image: food['dishimage'] != null
                  ? "https://backend.zenzio.in${food['dishimage']}"
                  : '',
            );
          }).toList();

          _deliveryFee = 50;
          _taxes = _cartItems.isNotEmpty ? (_itemTotal * 0.05) : 0;

          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "No active cart found.";
          });
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "⚠️ Error loading cart. Please try again later.";
      });
      debugPrint("❌ Error: $e");
    }
  }

  Future<void> _updateQuantity(String itemId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return;

      final url = Uri.parse('https://backend.zenzio.in/api/cart/items/$itemId');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Quantity updated successfully');
      } else {
        debugPrint('⚠️ Failed to update quantity: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating quantity: $e');
    }
  }

  Future<void> _removeItem(String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return;

      final url = Uri.parse('https://backend.zenzio.in/api/cart/items/$itemId');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Item removed successfully');
      } else {
        debugPrint('⚠️ Failed to remove item: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error removing item: $e');
    }
  }

  double get _itemTotal {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE53935)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Cart'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

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
          'My Cart',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _restaurantName.isNotEmpty
                                ? _restaurantName
                                : "Update later",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._cartItems.map((item) => _buildCartItem(item)),
                      const SizedBox(height: 12),

                      // ✅ Add More Items Button (with restaurantId)
                    TextButton.icon(
  onPressed: () async {
    debugPrint("🛒 Add More Items Clicked — Restaurant ID: $_restaurantId");

    // Check if restaurantId is available
    if (_restaurantId == null || _restaurantId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant details not available.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Navigate and wait until user comes back
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(
          restaurantId: _restaurantId!,
        ),
      ),
    );

    // ✅ Reload the cart when returning
    debugPrint("🔄 Returned from RestaurantDetailScreen — reloading cart...");
    await _fetchCartData();
    setState(() {});
  },
  icon: const Icon(Icons.add, color: Color(0xFFE53935)),
  label: const Text(
    'Add more items',
    style: TextStyle(
      color: Color(0xFFE53935),
      fontWeight: FontWeight.w500,
    ),
  ),
),

                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Apply Coupon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          hintText: 'Enter Coupon Code',
                          hintStyle: const TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE53935)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBillRow('Item Total', '₹${_itemTotal.toInt()}'),
                      _buildBillRow('Delivery Fee', '₹${_deliveryFee.toInt()}'),
                      _buildBillRow(
                        'Taxes & Charges',
                        '₹${_taxes.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE53935),
                            ),
                          ),
                          Text(
                            '₹${(_itemTotal + _deliveryFee + _taxes).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
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
          Container(
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
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _cartItems.isEmpty
                    ? null
                    : () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getString('user_id');

                        if (userId != null && _cartId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                userId: userId,
                                cartId: _cartId!,
                                total: _itemTotal + _deliveryFee + _taxes,
                              ),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.image.isNotEmpty
                ? Image.network(item.image, fit: BoxFit.cover)
                : const Icon(Icons.fastfood, color: Color(0xFFE0E0E0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isNotEmpty ? item.name : "Update later",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (item.quantity > 1) {
                          setState(() => item.quantity--);
                          await _updateQuantity(item.id, item.quantity);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE53935)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() => item.quantity++);
                        await _updateQuantity(item.id, item.quantity);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.price}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    _cartItems.remove(item);
                  });
                  await _removeItem(item.id);
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFFE53935),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
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

class CartItem {
  String id;
  String name;
  int price;
  int quantity;
  String image;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });
}


//   TextButton.icon(
//   onPressed: () {
//     debugPrint("🛒 Add More Items Clicked — Restaurant ID: $_restaurantId");

//     // Safely check for restaurant ID
//     if (_restaurantId == null || _restaurantId!.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Restaurant details not available.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // ✅ Navigate to restaurant detail screen and pass restaurantId
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RestaurantDetailScreen(
//           restaurantId: _restaurantId!,
//         ),
//       ),
//     );
//   },
//   icon: const Icon(Icons.add, color: Color(0xFFE53935)),
//   label: const Text(
//     'Add more items',
//     style: TextStyle(
//       color: Color(0xFFE53935),
//       fontWeight: FontWeight.w500,
//     ),
//   ),
// ),


//   import 'dart:convert';
//   import 'package:flutter/material.dart';
//   import 'package:http/http.dart' as http;
//   import 'package:shared_preferences/shared_preferences.dart';
//   import '../screens/restaurant_detail_screen.dart';

//   class CartScreen extends StatefulWidget {
//     const CartScreen({super.key});

//     @override
//     State<CartScreen> createState() => _CartScreenState();
//   }

//   class _CartScreenState extends State<CartScreen> {
//     final TextEditingController _couponController = TextEditingController();

//     bool _isLoading = true;
//     String? _errorMessage;
//     List<CartItem> _cartItems = [];
//     String _restaurantName = "Loading...";
//     String? _restaurantId;
//     Map<String, dynamic>? _restaurantData;
//     double _deliveryFee = 0;
//     double _taxes = 0;

//     @override
//     void initState() {
//       super.initState();
//       _fetchCartData();
//     }

//     Future<void> _fetchCartData() async {
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final userId = prefs.getString('user_id');

//         if (userId == null) throw Exception("User ID not found");

//         final url = Uri.parse(
//           'https://backend.zenzio.in/api/cart/active?userId=$userId',
//         );
//         final response = await http.get(url);

//         if (response.statusCode == 200) {
//           final data = json.decode(response.body);

//           if (data['success'] == true && data['cart'] != null) {
//             final cart = data['cart'];
//             final items = cart['items'] as List;

//             final restaurant = cart['items'][0]['food']['restaurant'];
//             _restaurantName = restaurant['rest_name'] ?? 'Unknown Restaurant';
//             _restaurantId = restaurant['_id'];
//             _restaurantData = restaurant;

//             _cartItems = items.map((item) {
//               final food = item['food'];
//               double unitPrice =
//                   double.tryParse(item['unitPrice'].toString()) ?? 0;
//               double addOnPrice = 0;
//               if (item['selectedAddOns'] != null) {
//                 for (var addOn in item['selectedAddOns']) {
//                   addOnPrice += double.tryParse(addOn['price'].toString()) ?? 0;
//                 }
//               }

//               return CartItem(
//                 id: item['id'],
//                 name: food['dishname'] ?? "Unknown Dish",
//                 price: (unitPrice + addOnPrice).toInt(),
//                 quantity: item['quantity'] ?? 1,
//                 image: food['dishimage'] != null
//                     ? "https://backend.zenzio.in${food['dishimage']}"
//                     : '',
//               );
//             }).toList();

//             _deliveryFee = 50;
//             _taxes = _cartItems.isNotEmpty ? (_itemTotal * 0.05) : 0;

//             setState(() {
//               _isLoading = false;
//             });
//           } else {
//             setState(() {
//               _isLoading = false;
//               _errorMessage = "No active cart found.";
//             });
//           }
//         } else {
//           throw Exception("Failed with status: ${response.statusCode}");
//         }
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = "⚠️ Error loading cart. Please try again later.";
//         });
//         debugPrint("❌ Error: $e");
//       }
//     }

//     Future<void> _updateQuantity(String itemId, int quantity) async {
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final userId = prefs.getString('user_id');
//         if (userId == null) return;

//         final url = Uri.parse('https://backend.zenzio.in/api/cart/items/$itemId');
//         final response = await http.put(
//           url,
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({'userId': userId, 'quantity': quantity}),
//         );

//         if (response.statusCode == 200) {
//           debugPrint('✅ Quantity updated successfully');
//         } else {
//           debugPrint('⚠️ Failed to update quantity: ${response.statusCode}');
//         }
//       } catch (e) {
//         debugPrint('❌ Error updating quantity: $e');
//       }
//     }

//     Future<void> _removeItem(String itemId) async {
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final userId = prefs.getString('user_id');
//         if (userId == null) return;

//         final url = Uri.parse('https://backend.zenzio.in/api/cart/items/$itemId');
//         final response = await http.delete(
//           url,
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({'userId': userId}),
//         );

//         if (response.statusCode == 200) {
//           debugPrint('✅ Item removed successfully');
//         } else {
//           debugPrint('⚠️ Failed to remove item: ${response.statusCode}');
//         }
//       } catch (e) {
//         debugPrint('❌ Error removing item: $e');
//       }
//     }

//     double get _itemTotal {
//       return _cartItems.fold(
//         0,
//         (sum, item) => sum + (item.price * item.quantity),
//       );
//     }

//     @override
//     void dispose() {
//       _couponController.dispose();
//       super.dispose();
//     }

//     @override
//     Widget build(BuildContext context) {
//       if (_isLoading) {
//         return const Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(color: Color(0xFFE53935)),
//           ),
//         );
//       }

//       if (_errorMessage != null) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('My Cart'),
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             elevation: 0,
//           ),
//           body: Center(
//             child: Text(
//               _errorMessage!,
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           ),
//         );
//       }

//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text(
//             'My Cart',
//             style: TextStyle(
//               color: Color(0xFF2D2D2D),
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.all(16),
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 24,
//                               height: 24,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: const Color(0xFFE0E0E0),
//                                   width: 2,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               _restaurantName.isNotEmpty
//                                   ? _restaurantName
//                                   : "Update later",
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF2D2D2D),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         ..._cartItems.map((item) => _buildCartItem(item)),
//                         const SizedBox(height: 12),
//                       TextButton.icon(
//   onPressed: () {
//     if (_restaurantId == null || _restaurantId!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Restaurant details not available.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RestaurantDetailScreen(
//           restaurantId: _restaurantId!,
//           restaurant: const {}, // send empty map or remove this if not required
//         ),
//       ),
//     );
//   },
//   icon: const Icon(Icons.add, color: Color(0xFFE53935)),
//   label: const Text(
//     'Add more items',
//     style: TextStyle(
//       color: Color(0xFFE53935),
//       fontWeight: FontWeight.w500,
//     ),
//   ),
// ),


//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Apply Coupon',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _couponController,
//                           decoration: InputDecoration(
//                             hintText: 'Enter Coupon Code',
//                             hintStyle: const TextStyle(
//                               color: Color(0xFFBDBDBD),
//                               fontSize: 14,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: const BorderSide(
//                                 color: Color(0xFFE0E0E0),
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: const BorderSide(
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 14,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       ElevatedButton(
//                         onPressed: () {},
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFE53935),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 24,
//                             vertical: 14,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: const Text(
//                           'Apply',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Bill Details',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF2D2D2D),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildBillRow('Item Total', '₹${_itemTotal.toInt()}'),
//                         _buildBillRow('Delivery Fee', '₹${_deliveryFee.toInt()}'),
//                         _buildBillRow(
//                           'Taxes & Charges',
//                           '₹${_taxes.toStringAsFixed(2)}',
//                         ),
//                         const Divider(height: 24),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Grand Total',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                             Text(
//                               '₹${(_itemTotal + _deliveryFee + _taxes).toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFFE53935),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _cartItems.isEmpty
//                       ? null
//                       : () {
//                           Navigator.pushNamed(context, '/checkout');
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFE53935),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     'Proceed to Checkout',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     Widget _buildCartItem(CartItem item) {
//       return Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         child: Row(
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: item.image.isNotEmpty
//                   ? Image.network(item.image, fit: BoxFit.cover)
//                   : const Icon(Icons.fastfood, color: Color(0xFFE0E0E0)),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.name.isNotEmpty ? item.name : "Update later",
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () async {
//                           if (item.quantity > 1) {
//                             setState(() => item.quantity--);
//                             await _updateQuantity(item.id, item.quantity);
//                           }
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: const Color(0xFFE53935)),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: const Icon(
//                             Icons.remove,
//                             size: 16,
//                             color: Color(0xFFE53935),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: Text(
//                           '${item.quantity}',
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () async {
//                           setState(() => item.quantity++);
//                           await _updateQuantity(item.id, item.quantity);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFE53935),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: const Icon(
//                             Icons.add,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '₹${item.price}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 GestureDetector(
//                   onTap: () async {
//                     setState(() {
//                       _cartItems.remove(item);
//                     });
//                     await _removeItem(item.id);
//                   },
//                   child: const Row(
//                     children: [
//                       Icon(
//                         Icons.delete_outline,
//                         size: 16,
//                         color: Color(0xFFE53935),
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         'Remove',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFFE53935),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     }

//     Widget _buildBillRow(String label, String value) {
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 12),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
//             ),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   class CartItem {
//     String id;
//     String name;
//     int price;
//     int quantity;
//     String image;

//     CartItem({
//       required this.id,
//       required this.name,
//       required this.price,
//       required this.quantity,
//       required this.image,
//     });
//   }

// import 'package:flutter/material.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   final TextEditingController _couponController = TextEditingController();

//   final List<CartItem> _cartItems = [
//     CartItem(
//       name: 'Beef Burger',
//       price: 129,
//       quantity: 1,
//       image: 'assets/burger.jpg',
//     ),
//     CartItem(
//       name: 'Cheese Fries',
//       price: 599,
//       quantity: 2,
//       image: 'assets/fries.jpg',
//     ),
//     CartItem(
//       name: 'Chocolate Milkshake',
//       price: 450,
//       quantity: 1,
//       image: 'assets/milkshake.jpg',
//     ),
//   ];

//   @override
//   void dispose() {
//     _couponController.dispose();
//     super.dispose();
//   }

//   double get _itemTotal {
//     return _cartItems.fold(
//         0, (sum, item) => sum + (item.price * item.quantity));
//   }

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
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             width: 24,
//                             height: 24,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: const Color(0xFFE0E0E0),
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Text(
//                             'Burger Kingdom',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF2D2D2D),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       ..._cartItems.map((item) => _buildCartItem(item)),
//                       const SizedBox(height: 12),
//                       TextButton.icon(
//                         onPressed: () {
//                           Navigator.pushNamed(context, '/restaurant-detail');
//                         },
//                         icon: const Icon(Icons.add, color: Color(0xFFE53935)),
//                         label: const Text(
//                           'Add more items',
//                           style: TextStyle(
//                             color: Color(0xFFE53935),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Apply Coupon',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _couponController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter Coupon Code',
//                           hintStyle: const TextStyle(
//                             color: Color(0xFFBDBDBD),
//                             fontSize: 14,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: const BorderSide(
//                               color: Color(0xFFE0E0E0),
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: const BorderSide(
//                               color: Color(0xFFE0E0E0),
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: const BorderSide(
//                               color: Color(0xFFE53935),
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 14,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE53935),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 14,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text(
//                         'Apply',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Bill Details',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2D2D2D),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildBillRow('Item Total', '₹${_itemTotal.toInt()}'),
//                       _buildBillRow('Delivery Fee', '₹2.99'),
//                       _buildBillRow('Taxes & Charges', '₹3.25'),
//                       const Divider(height: 24),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Grand Total',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFFE53935),
//                             ),
//                           ),
//                           Text(
//                             '₹35.71',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFFE53935),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
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
//                   Navigator.pushNamed(context, '/checkout');
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

//   Widget _buildCartItem(CartItem item) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
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
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.name,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           if (item.quantity > 1) item.quantity--;
//                         });
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: const Color(0xFFE53935)),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Icon(
//                           Icons.remove,
//                           size: 16,
//                           color: Color(0xFFE53935),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: Text(
//                         '${item.quantity}',
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() => item.quantity++);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFE53935),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Icon(
//                           Icons.add,
//                           size: 16,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '₹${item.price}',
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2D2D2D),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _cartItems.remove(item);
//                   });
//                 },
//                 child: const Row(
//                   children: [
//                     Icon(
//                       Icons.delete_outline,
//                       size: 16,
//                       color: Color(0xFFE53935),
//                     ),
//                     SizedBox(width: 4),
//                     Text(
//                       'Remove',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFFE53935),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
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

// class CartItem {
//   String name;
//   int price;
//   int quantity;
//   String image;

//   CartItem({
//     required this.name,
//     required this.price,
//     required this.quantity,
//     required this.image,
//   });

//   Object? toJson() {}
// }
