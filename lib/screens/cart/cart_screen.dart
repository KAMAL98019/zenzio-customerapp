// import 'package:flutter/material.dart';
// import 'package:zenzio_customer/screens/home/restaurant_detail_screen.dart';
// import 'package:zenzio_customer/screens/cart/checkout_screen.dart';
// import 'package:zenzio_customer/services/restaurant_service.dart';
// import 'package:zenzio_customer/services/token_service.dart';
// import 'package:zenzio_customer/services/cart_service.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   final TextEditingController _couponController = TextEditingController();
//   final CartService _cartService = CartService();
// // final cartDetails = await _cartService.getCartDetailsWithRestaurant(_restaurantId!);

//   bool _isLoading = true;
//   String? _errorMessage;
//   List<CartItem> _cartItems = [];
//   String _restaurantName = "Loading...";
//   String? _restaurantId;
//   String? _cartGroupUid; // ✅ Added to store cart_group_uid
//   double _deliveryFee = 0;
//   double _taxes = 0;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final args = ModalRoute.of(context)?.settings.arguments;
//     if (args != null && args is String) {
//       _restaurantId = args;
//       print("📌 Received Restaurant ID => $_restaurantId");
//     }

//     _fetchCartData();
//   }

  // Future<void> _fetchCartData() async {
  //   if (!mounted) return;

  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   String? errorMessage;
  //   try {
  //     final tokenService = TokenService();
  //     final userId = await tokenService.getUserId();
  //     if (userId == null) throw Exception("User ID not found");

  //     if (_restaurantId != null) {
  //       // ✅ Use getCartDetails instead of fetchRestaurantItems to get cart_group_uid
  //       final cartDetails = await _cartService.getCartDetails(_restaurantId!);
  //       final items = cartDetails["items"] ?? [];
        
  //       // ✅ Extract cart_group_uid
  //       _cartGroupUid = cartDetails["cart_group_uid"];
  //       print("✅ Cart Group UID: $_cartGroupUid");

  //       print("🔹 Fetched ${items.length} items from API");

  //       _cartItems = items.map<CartItem>((item) {
  //         print("🔹 Raw item data => $item");

  //         // ✅ CRITICAL: Use database ID for API calls
  //         int dbId = item['id'] ?? 0;
  //         String cartItemUid = item['cart_item_uid'] ?? '';
          
  //         double unitPrice = double.tryParse(item['price']?.toString() ?? "0") ?? 0;
  //         int quantity = item['qty'] ?? 1;
          
  //         const String dummyImage = "https://via.placeholder.com/150";

  //         print("✅ Mapped: dbId=$dbId, uid=$cartItemUid, qty=$quantity");

  //         return CartItem(
  //           id: dbId,             // ✅ Database ID for API calls
  //           uid: cartItemUid,     // UID for reference
  //           name: item['menu_name'] ?? "Unknown Dish",
  //           price: unitPrice.toInt(),
  //           quantity: quantity,
  //           image: dummyImage,
  //         );
  //       }).toList();

  //       print("✅ Total cart items mapped: ${_cartItems.length}");
  //     }

  //     _restaurantName = _restaurantId ?? "Unknown Restaurant";
  //     _deliveryFee = 50;
  //     _taxes = _cartItems.isNotEmpty ? (_itemTotal * 0.05) : 0;
  //   } catch (e) {
  //     errorMessage = "⚠️ Error loading cart: $e";
  //     print(errorMessage);
  //   } finally {
  //     if (!mounted) return;
  //     setState(() {
  //       _isLoading = false;
  //       _errorMessage = errorMessage;
  //     });
  //   }
  // }
  
  import 'package:flutter/material.dart';
import 'package:zenzio_customer/screens/home/restaurant_detail_screen.dart';
import 'package:zenzio_customer/screens/cart/checkout_screen.dart';
import 'package:zenzio_customer/services/restaurant_service.dart';
import 'package:zenzio_customer/services/token_service.dart';
import 'package:zenzio_customer/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  final CartService _cartService = CartService();
// final cartDetails = await _cartService.getCartDetailsWithRestaurant(_restaurantId!);

  bool _isLoading = true;
  String? _errorMessage;
  List<CartItem> _cartItems = [];
  String _restaurantName = "Loading...";
  String? _restaurantId;
  String? _cartGroupUid; // ✅ Added to store cart_group_uid
  double _deliveryFee = 0;
  double _taxes = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _restaurantId = args;
      print("📌 Received Restaurant ID => $_restaurantId");
    }

    _fetchCartData();
  }

  Future<void> _fetchCartData() async {
  if (!mounted) return;

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  String? errorMessage;
  try {
    final tokenService = TokenService();
    final userId = await tokenService.getUserId();
    if (userId == null) throw Exception("User ID not found");

    if (_restaurantId != null) {
      // ✅ Get cart details which should include restaurant info
      final cartDetails = await _cartService.getCartDetails(_restaurantId!);
      final items = cartDetails["items"] ?? [];
      
      // ✅ Extract cart_group_uid
      _cartGroupUid = cartDetails["cart_group_uid"];
      print("✅ Cart Group UID: $_cartGroupUid");

      // ✅ Extract restaurant details from cart response
      final restaurantData = cartDetails["restaurant"];
      if (restaurantData != null) {
        _restaurantName = restaurantData["restaurant_name"] ?? 
                         restaurantData["rest_name"] ?? 
                         "Unknown Restaurant";
        print("✅ Restaurant Name: $_restaurantName");
      } else {
        // ✅ Fallback: Fetch restaurant details separately if not in cart response
        print("⚠️ Restaurant details not in cart response, fetching separately...");
        try {
          final restaurantService = RestaurantService();
          final restaurant = await restaurantService.fetchRestaurantById(_restaurantId!);
          _restaurantName = restaurant.restName;
          print("✅ Fetched Restaurant Name: $_restaurantName");
        } catch (e) {
          print("❌ Failed to fetch restaurant details: $e");
          _restaurantName = "Restaurant";
        }
      }

      print("🔹 Fetched ${items.length} items from API");

      _cartItems = items.map<CartItem>((item) {
        print("🔹 Raw item data => $item");

        // ✅ CRITICAL: Use database ID for API calls
        int dbId = item['id'] ?? 0;
        String cartItemUid = item['cart_item_uid'] ?? '';
        
        double unitPrice = double.tryParse(item['price']?.toString() ?? "0") ?? 0;
        int quantity = item['qty'] ?? 1;
        
        const String dummyImage = "https://via.placeholder.com/150";

        print("✅ Mapped: dbId=$dbId, uid=$cartItemUid, qty=$quantity");

        return CartItem(
          id: dbId,             // ✅ Database ID for API calls
          uid: cartItemUid,     // UID for reference
          name: item['menu_name'] ?? "Unknown Dish",
          price: unitPrice.toInt(),
          quantity: quantity,
          image: dummyImage,
        );
      }).toList();

      print("✅ Total cart items mapped: ${_cartItems.length}");
    }

    _deliveryFee = 50;
    _taxes = _cartItems.isNotEmpty ? (_itemTotal * 0.05) : 0;
  } catch (e) {
    errorMessage = "⚠️ Error loading cart: $e";
    print(errorMessage);
  } finally {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = errorMessage;
    });
  }
}

  Future<void> _updateQuantity(int itemId, int quantity) async {
    print('📤 Updating item => ID: $itemId, Quantity: $quantity');
    
    if (itemId <= 0) {
      throw Exception('Invalid item ID');
    }
    
    if (quantity < 1) {
      throw Exception('Quantity must be at least 1');
    }

    try {
      await _cartService.updateItemQuantity(itemId.toString(), quantity);
      print("✅ Quantity updated successfully: $itemId -> $quantity");
    } catch (e) {
      print("❌ Error updating quantity: $e");
      rethrow;
    }
  }

  Future<void> _removeItem(int itemId) async {
    print('📤 Removing item => ID: $itemId');

    if (itemId <= 0) {
      throw Exception('Invalid item ID');
    }

    try {
      await _cartService.removeCartItem(itemId.toString());
      print("🗑️ Item removed successfully: $itemId");
    } catch (e) {
      print("❌ Error removing item: $e");
      rethrow;
    }
  }

  double get _itemTotal {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  double get _grandTotal {
    return _itemTotal + _deliveryFee + _taxes;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCartData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                ),
                child: const Text('Retry'),
              ),
            ],
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
                          Expanded(
                            child: Text(
                              _restaurantName.isNotEmpty
                                  ? _restaurantName
                                  : "Update later",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_cartItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'Your cart is empty',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),
                        )
                      else
                        ..._cartItems.map((item) => _buildCartItem(item)),
                      const SizedBox(height: 12),
                     // In your CartScreen, update the "Add more items" button:

TextButton.icon(
  onPressed: () async {
    if (_restaurantId == null || _restaurantId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant details not available.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // ✅ Navigate with only restaurant ID
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(
          restaurantId: _restaurantId!, // Pass only ID
        ),
      ),
    );

    await _fetchCartData();
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
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE53935),
                            ),
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coupon feature coming soon!'),
                          ),
                        );
                      },
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
                      _buildBillRow('Item Total', '₹${_itemTotal.toStringAsFixed(2)}'),
                      _buildBillRow('Delivery Fee', '₹${_deliveryFee.toStringAsFixed(2)}'),
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
                            '₹${_grandTotal.toStringAsFixed(2)}',
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
                onPressed: _cartItems.isEmpty || _cartGroupUid == null
                    ? null
                    : () async {
                        // ✅ Navigate to CheckoutScreen with all necessary data
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              cartGroupUid: _cartGroupUid!,
                              restaurantId: _restaurantId!,
                              cartItems: _cartItems,
                              itemTotal: _itemTotal,
                              deliveryFee: _deliveryFee,
                              taxes: _taxes,
                              grandTotal: _grandTotal,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  // disabledBackgroundColor: Colors.grey[300],
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
                ? Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.fastfood, color: Color(0xFFE0E0E0));
                    },
                  )
                : const Icon(Icons.fastfood, color: Color(0xFFE0E0E0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isNotEmpty ? item.name : "Unknown Item",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.price} each',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (item.quantity > 1) {
                          final newQty = item.quantity - 1;

                          try {
                            // API call with database ID
                            await _updateQuantity(item.id, newQty);

                            if (!mounted) return;

                            // Update UI after successful API call
                            setState(() {
                              item.quantity = newQty;
                              _taxes = _itemTotal * 0.05;
                            });
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
                        final newQty = item.quantity + 1;

                        try {
                          // API call with database ID
                          await _updateQuantity(item.id, newQty);

                          if (!mounted) return;

                          // Update UI after successful API call
                          setState(() {
                            item.quantity = newQty;
                            _taxes = _itemTotal * 0.05;
                          });
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
                '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  try {
                    // Remove from API using database ID
                    await _removeItem(item.id);

                    if (!mounted) return;

                    // Update UI after successful removal
                    setState(() {
                      _cartItems.remove(item);
                      _taxes = _cartItems.isNotEmpty ? (_itemTotal * 0.05) : 0;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item removed from cart'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to remove: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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

// ✅ FIXED CartItem Model
class CartItem {
  int id;         // Database ID (e.g., 1, 16) - Used for API calls
  String uid;     // cart_item_uid (e.g., "CITEM-GYK16Y9") - For reference
  String name;
  int price;
  int quantity;
  String image;

  CartItem({
    required this.id,       // This should be the numeric database ID
    required this.uid,      // This should be cart_item_uid
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });
}  


// main import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:zenzio_customer/screens/home/restaurant_detail_screen.dart';
// import 'package:zenzio_customer/screens/cart/checkout_screen.dart';
// import 'package:zenzio_customer/services/token_service.dart';
// import 'package:zenzio_customer/services/cart_service.dart';
// import 'package:zenzio_customer/data/models/cart_model.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   final TextEditingController _couponController = TextEditingController();
//   final CartService _cartService = CartService();

//   bool _isLoading = true;
//   String? _errorMessage;
//   List<CartItem> _cartItems = [];
//   String _restaurantName = "Loading...";
//   String? _restaurantId;
//   String? _cartId;
//   Map<String, dynamic>? _restaurantData;
//   double _deliveryFee = 0;
//   double _taxes = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCartData();
//   }

//   /// ✅ NEW: Fetch cart using CartService
//   Future<void> _fetchCartData() async {
//     String? errorMessage;

//     try {
//       // Fetch cart items using the new service
//       final items = await _cartService.fetchCartItems();

//       if (items.isEmpty) {
//         errorMessage = "No active cart found.";
//       } else {
//         _cartItems = items;

//         // Extract restaurant info from first item
//         if (_cartItems.isNotEmpty && _cartItems[0].food != null) {
//           final restaurant = _cartItems[0].food!['restaurant'];
//           if (restaurant != null) {
//             _restaurantName = restaurant['rest_name'] ?? 'Unknown Restaurant';
//             _restaurantId = restaurant['_id'] ?? restaurant['id'] ?? '';
//             debugPrint("🍽 Restaurant ID fetched: $_restaurantId");
//           }
//         }

//         // Calculate fees
//         _deliveryFee = 50;
//         _taxes = _cartItems.isNotEmpty ? (_itemTotal * 0.05) : 0;
//       }
//     } catch (e) {
//       debugPrint("❌ Error: $e");
//       errorMessage = "⚠️ Error loading cart. Please try again later.";
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _errorMessage = errorMessage;
//       });
//     }
//   }

//   /// ✅ NEW: Update quantity using CartService
//   Future<void> _updateQuantity(String itemId, int quantity) async {
//     try {
//       await _cartService.updateItemQuantity(itemId, quantity);
//       debugPrint('✅ Quantity updated successfully');
//     } catch (e) {
//       debugPrint('❌ Error updating quantity: $e');
//       // Optionally show error to user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to update quantity'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   /// ✅ NEW: Remove item using CartService
//   Future<void> _removeItem(String itemId) async {
//     try {
//       await _cartService.removeCartItem(itemId);
//       debugPrint('✅ Item removed successfully');
//     } catch (e) {
//       debugPrint('❌ Error removing item: $e');
//       // Optionally show error to user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to remove item'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   double get _itemTotal {
//     return _cartItems.fold(
//       0,
//       (sum, item) => sum + (item.price * item.quantity),
//     );
//   }

//   Future<Map<String, dynamic>?> _createPaymentOrder() async {
//     try {
//       final tokenService = TokenService();
//       final userId = await tokenService.getUserId();

//       debugPrint("🛒 userid ID: $userId");
//       debugPrint("🛒 Cart ID: $_cartId");
      
//       if (userId == null || _cartId == null) {
//         debugPrint('⚠️ User ID or Cart ID missing');
//         return null;
//       }

//       final url = Uri.parse('https://backend.zenzio.in/api/orders/create-payment-order');
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${await tokenService.getToken()}',
//         },
//         body: jsonEncode({
//           'userId': userId,
//           'cartId': _cartId,
//         }),
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         debugPrint("✅ Payment order created: $data");
//         return data;
//       } else {
//         debugPrint('⚠️ Failed to create payment order: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('❌ Error creating payment order: $e');
//       return null;
//     }
//   }

//   @override
//   void dispose() {
//     _couponController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(color: Color(0xFFE53935)),
//         ),
//       );
//     }

//     if (_errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('My Cart'),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0,
//         ),
//         body: Center(
//           child: Text(
//             _errorMessage!,
//             style: const TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         ),
//       );
//     }

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
//                           Text(
//                             _restaurantName.isNotEmpty
//                                 ? _restaurantName
//                                 : "Update later",
//                             style: const TextStyle(
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
//                         onPressed: () async {
//                           debugPrint(
//                             "🛒 Add More Items Clicked — Restaurant ID: $_restaurantId",
//                           );

//                           if (_restaurantId == null ||
//                               _restaurantId!.trim().isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'Restaurant details not available.',
//                                 ),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                             return;
//                           }

//                           await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => RestaurantDetailScreen(
//                                 restaurantId: _restaurantId!,
//                               ),
//                             ),
//                           );

//                           debugPrint(
//                             "🔄 Returned from RestaurantDetailScreen — reloading cart...",
//                           );
//                           await _fetchCartData();
//                           setState(() {});
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
//                       _buildBillRow('Delivery Fee', '₹${_deliveryFee.toInt()}'),
//                       _buildBillRow(
//                         'Taxes & Charges',
//                         '₹${_taxes.toStringAsFixed(2)}',
//                       ),
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
//                             '₹${(_itemTotal + _deliveryFee + _taxes).toStringAsFixed(2)}',
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
//                 onPressed: _cartItems.isEmpty
//                     ? null
//                     : () async {
//                         final paymentData = await _createPaymentOrder();

//                         if (paymentData != null && paymentData['success'] == true) {
//                           final userId = await TokenService().getUserId();

//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CheckoutScreen(
//                                 userId: userId!,
//                                 cartId: _cartId!,
//                                 total: _itemTotal + _deliveryFee + _taxes,
//                                 totalAmount: _itemTotal + _deliveryFee + _taxes,
//                                 restaurantId: _restaurantId!,
//                                 razorpayOrderId: paymentData['razorpayOrderId'],
//                                 currency: paymentData['currency'],
//                                 amount: paymentData['amount'],
//                                 key: paymentData['key'],
//                               ),
//                             ),
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Failed to create payment order.'),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                         }
//                       },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   'Proceed to Checkout',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
//             child: item.image.isNotEmpty
//                 ? Image.network(item.image, fit: BoxFit.cover)
//                 : const Icon(Icons.fastfood, color: Color(0xFFE0E0E0)),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.name.isNotEmpty ? item.name : "Update later",
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
//                       onTap: () async {
//                         if (item.quantity > 1) {
//                           setState(() => item.quantity--);
//                           await _updateQuantity(item.id, item.quantity);
//                         }
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
//                       onTap: () async {
//                         setState(() => item.quantity++);
//                         await _updateQuantity(item.id, item.quantity);
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
//                 onTap: () async {
//                   setState(() {
//                     _cartItems.remove(item);
//                   });
//                   await _removeItem(item.id);
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
//             style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
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
