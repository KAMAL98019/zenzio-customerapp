// import 'package:flutter/material.dart';
// import 'package:zenzio_customer/data/models/cart_model.dart';
// import 'package:zenzio_customer/services/cart_service.dart';
// import '../services/restaurant_service.dart';
// import '../data/models/food_model.dart';

// class RestaurantDetailScreen extends StatefulWidget {
//   final String restaurantId;
//   final Map<String, dynamic> restaurant;

//   const RestaurantDetailScreen({
//     super.key,
//     required this.restaurantId,
//     required this.restaurant,
//   });

//   @override
//   State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
// }

// // ✅ CRITICAL FIX: Changed from SingleTickerProviderStateMixin to TickerProviderStateMixin
// class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
//     with TickerProviderStateMixin {  // ← Changed here
//   late TabController _tabController;
//   final RestaurantService _restaurantService = RestaurantService();

//   List<Food> _foods = [];
//   Map<String, List<Food>> _groupedFoods = {};
//   List<String> _categories = [];
//   bool _isLoading = true;
//   bool _hasError = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     print('🍽️ RestaurantDetailScreen initState for: ${widget.restaurant['rest_name']}');
    
//     // ✅ Initialize with length 1 first to avoid errors
//     _tabController = TabController(length: 1, vsync: this);
    
//     // ✅ Fetch data after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         _fetchRestaurantFoods();
//       }
//     });
//   }

//   Future<void> _fetchRestaurantFoods() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//       _errorMessage = null;
//     });

//     try {
//       print('🌐 Fetching foods for restaurant: ${widget.restaurantId}');
      
//       final grouped = await _restaurantService
//           .fetchRestaurantFoodsWithCategories(widget.restaurantId)
//           .timeout(
//             const Duration(seconds: 15),
//             onTimeout: () {
//               throw Exception('Request timeout - please check your connection');
//             },
//           );

//       if (!mounted) return;

//       final categories = grouped.keys.toList();
//       final allFoods = grouped.values.expand((list) => list).toList();

//       print('✅ Loaded ${allFoods.length} foods in ${categories.length} categories');

//       // ✅ Safely update TabController
//       final newLength = categories.isNotEmpty ? categories.length : 1;
      
//       // Dispose old controller
//       _tabController.dispose();
      
//       // Create new controller with correct length
//       _tabController = TabController(
//         length: newLength,
//         vsync: this,
//       );

//       if (mounted) {
//         setState(() {
//           _foods = allFoods;
//           _groupedFoods = grouped;
//           _categories = categories;
//           _isLoading = false;
//         });
//       }
//     } catch (e, stackTrace) {
//       print('❌ Error fetching foods: $e');
//       print('📍 Stack trace: $stackTrace');
      
//       if (!mounted) return;

//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     print('🍽️ RestaurantDetailScreen disposing');
//     _tabController.dispose();
//     super.dispose();
//   }

//   String _getImageUrl(String? path) {
//     if (path == null || path.isEmpty) return '';
//     if (path.startsWith('http')) return path;
    
//     String cleanPath = path.replaceFirst("/root/choozy-backend", "");
//     return 'https://backend.zenzio.in$cleanPath';
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print('🍽️ RestaurantDetailScreen building...');
//      print('🔍 RestaurantDetailScreen received:');
//   print('   restaurantId: ${widget.restaurantId}');
//   print('   restaurant keys: ${widget.restaurant.keys.toList()}');
//   print('   rest_name: ${widget.restaurant['rest_name']}');
//   print('   rest_address: ${widget.restaurant['rest_address']}');
//   print('   avg_cost_two: ${widget.restaurant['avg_cost_two']}');

//     final restaurant = widget.restaurant;
//     final imageUrl = _getImageUrl(restaurant['rest_logo']);
//     final name = restaurant['rest_name']?.toString() ?? 'Restaurant';
//     final address = restaurant['rest_address']?.toString() ?? '';
//     final avgCost = restaurant['avg_cost_two']?.toString() ?? '0';

//  print('   ✅ Parsed name: $name');
//   print('   ✅ Parsed address: $address');
//   print('   ✅ Parsed avgCost: $avgCost');

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           // ===== AppBar with image =====
//           SliverAppBar(
//             expandedHeight: 200,
//             pinned: true,
//             backgroundColor: const Color(0xFFE53935),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.favorite_border, color: Colors.white),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.share, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               background: imageUrl.isNotEmpty
//                   ? Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Container(
//                           color: const Color(0xFFF5F5F5),
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               value: loadingProgress.expectedTotalBytes != null
//                                   ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                   : null,
//                               valueColor: const AlwaysStoppedAnimation<Color>(
//                                 Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                       errorBuilder: (_, error, __) {
//                         print('❌ Restaurant image load error: $error');
//                         return Container(
//                           color: const Color(0xFFF5F5F5),
//                           child: const Center(
//                             child: Icon(
//                               Icons.restaurant,
//                               size: 80,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         );
//                       },
//                     )
//                   : Container(
//                       color: const Color(0xFFF5F5F5),
//                       child: const Center(
//                         child: Icon(
//                           Icons.restaurant,
//                           size: 80,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//             ),
//           ),

//           // ===== Restaurant Info + Tabs =====
//           SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // --- Basic info ---
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         name,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2D2D2D),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         address,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF757575),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.currency_rupee,
//                             size: 16,
//                             color: Color(0xFFE53935),
//                           ),
//                           Text(
//                             '$avgCost for two',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // --- Loading/Error states ---
//                 if (_isLoading)
//                   Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(32),
//                       child: Column(
//                         children: const [
//                           CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Color(0xFFE53935),
//                             ),
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'Loading menu...',
//                             style: TextStyle(color: Color(0xFF757575)),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 else if (_hasError)
//                   Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(32),
//                       child: Column(
//                         children: [
//                           const Icon(
//                             Icons.error_outline,
//                             size: 64,
//                             color: Colors.red,
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Failed to load menu',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           if (_errorMessage != null) ...[
//                             const SizedBox(height: 8),
//                             Text(
//                               _errorMessage!,
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                           const SizedBox(height: 16),
//                           ElevatedButton.icon(
//                             onPressed: _fetchRestaurantFoods,
//                             icon: const Icon(Icons.refresh),
//                             label: const Text('Retry'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFE53935),
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 else if (_categories.isEmpty)
//                   const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(32),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.restaurant_menu,
//                             size: 64,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'No menu items available',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'This restaurant hasn\'t added any items yet.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 else
//                   // --- Category Tabs ---
//                   Container(
//                     color: const Color(0xFFF5F5F5),
//                     child: TabBar(
//                       controller: _tabController,
//                       isScrollable: true,
//                       labelColor: const Color(0xFFE53935),
//                       unselectedLabelColor: const Color(0xFF757575),
//                       indicatorColor: const Color(0xFFE53935),
//                       labelStyle: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       tabs: _categories.map((cat) => Tab(text: cat)).toList(),
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // ===== TabBar View =====
//           if (!_isLoading && !_hasError && _categories.isNotEmpty)
//             SliverFillRemaining(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: _categories
//                     .map((cat) => _buildCategoryMenu(cat))
//                     .toList(),
//               ),
//             ),
//         ],
//       ),

//       // ===== Floating Cart Button =====
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xFFE53935),
//         onPressed: () {
//           try {
//             Navigator.pushNamed(context, '/cart-rest');
//           } catch (e) {
//             print('❌ Cart navigation error: $e');
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Error opening cart: $e'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         child: const Icon(Icons.shopping_cart, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildCategoryMenu(String category) {
//     final foods = _groupedFoods[category] ?? [];
//     if (foods.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(32),
//           child: Text('No items in this category'),
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Text(
//           category,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D2D2D),
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...foods.map(_buildMenuItem).toList(),
//       ],
//     );
//   }

//   Widget _buildMenuItem(Food food) {
//     final imageUrl = _getImageUrl(food.image);
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//       ),
//       child: Row(
//         children: [
//           // Food Image
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5F5),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: imageUrl.isNotEmpty
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return const Center(
//                           child: SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           ),
//                         );
//                       },
//                       errorBuilder: (_, __, ___) => const Icon(
//                         Icons.restaurant_menu,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   )
//                 : const Icon(Icons.restaurant_menu, color: Colors.grey),
//           ),
//           const SizedBox(width: 12),
//           // Food Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     // Veg/Non-veg indicator
//                     Container(
//                       width: 16,
//                       height: 16,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: food.veg ? Colors.green : Colors.red,
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Center(
//                         child: Container(
//                           width: 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: food.veg ? Colors.green : Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         food.foodName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (food.description?.isNotEmpty ?? false) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     food.description!,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 13, color: Colors.grey),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           // Price and Add Button
//           Column(
//             children: [
//               Text(
//                 '₹${food.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () => _showAddItemSheet(food),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFE53935),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.add, color: Colors.white, size: 20),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddItemSheet(Food food) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: AddItemSheet(food: food),
//       ),
//     );
//   }
// }

// // Rest of the AddItemSheet code remains the same...

// // AddItemSheet remains exactly the same - no changes needed
// class AddItemSheet extends StatefulWidget {
//   final Food food;
//   const AddItemSheet({super.key, required this.food});
  
//   get restaurantId => null;

//   @override
//   State<AddItemSheet> createState() => _AddItemSheetState();
// }

// class _AddItemSheetState extends State<AddItemSheet> {
//   int _quantity = 1;
//   String _size = 'Medium';
//   String _spice = 'Medium';

//   double get _total {
//     double base = widget.food.price;
//     double extra = _size == 'Large'
//         ? 40
//         : _size == 'Small'
//         ? -50
//         : 0;
//     return (base + extra) * _quantity;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               // Veg/Non-veg indicator
//               Container(
//                 width: 20,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: widget.food.veg ? Colors.green : Colors.red,
//                     width: 2,
//                   ),
//                 ),
//                 child: Center(
//                   child: Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: widget.food.veg ? Colors.green : Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   widget.food.foodName,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               Text(
//                 '₹${widget.food.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           if (widget.food.description?.isNotEmpty ?? false)
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text(
//                 widget.food.description!,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ),
//           const SizedBox(height: 24),
//           // Quantity
//           Row(
//             children: [
//               const Text(
//                 'Quantity',
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xFFE53935)),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.remove,
//                     color: Color(0xFFE53935),
//                     size: 16,
//                   ),
//                 ),
//                 onPressed: () {
//                   if (_quantity > 1) setState(() => _quantity--);
//                 },
//               ),
//               Text(
//                 '$_quantity',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               IconButton(
//                 icon: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFE53935),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.add, color: Colors.white, size: 16),
//                 ),
//                 onPressed: () => setState(() => _quantity++),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Choose your size',
//             style: TextStyle(fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           _buildSizeOption('Small', '-₹50'),
//           _buildSizeOption('Medium', '₹0'),
//           _buildSizeOption('Large', '+₹40'),
//           const SizedBox(height: 16),
//           const Text(
//             'Choose spice level',
//             style: TextStyle(fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           _buildSpiceOption('Mild'),
//           _buildSpiceOption('Medium'),
//           _buildSpiceOption('Hot'),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             height: 56,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFE53935),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () async {
//                 try {
//                   final cartService = CartService();

//                  final item = CartItem(
//   foodId: widget.food.id,
//   quantity: _quantity,
//   selectedAddOns: [
//     if (_size == 'Large') AddOn(name: 'Large Size', price: 40),
//     if (_size == 'Small') AddOn(name: 'Small Size', price: -50),
//     AddOn(name: 'Spice: $_spice', price: 0),
//   ],
// );



//                   final success = await cartService.addToCart(item);

//                   if (!mounted) return;
//                   Navigator.pop(context);

//                   if (success) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                           '${widget.food.foodName} added to cart successfully',
//                         ),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Failed to add item to cart'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   print('❌ Add to cart error: $e');
//                   if (!mounted) return;
                  
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               child: Text(
//                 'Add to Cart - ₹${_total.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSizeOption(String size, String price) => GestureDetector(
//         onTap: () => setState(() => _size = size),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: _size == size
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFFE0E0E0),
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 _size == size
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//                 color: _size == size ? const Color(0xFFE53935) : Colors.grey,
//               ),
//               const SizedBox(width: 8),
//               Text(size),
//               const Spacer(),
//               Text(price),
//             ],
//           ),
//         ),
//       );

//   Widget _buildSpiceOption(String spice) => GestureDetector(
//         onTap: () => setState(() => _spice = spice),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: _spice == spice
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFFE0E0E0),
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 _spice == spice
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//                 color: _spice == spice ? const Color(0xFFE53935) : Colors.grey,
//               ),
//               const SizedBox(width: 8),
//               Text(spice),
//             ],
//           ),
//         ),
//       );
// }



// import 'package:flutter/material.dart';
// import 'package:zenzio_customer/data/models/cart_model.dart';
// import 'package:zenzio_customer/services/cart_service.dart';
// import '../../services/restaurant_service.dart';
// import '../../data/models/food_model.dart';
// import '../../data/models/restaurant_model.dart';

// class RestaurantDetailScreen extends StatefulWidget {
//   final String restaurantId;

//   const RestaurantDetailScreen({
//     super.key,
//     required this.restaurantId,
//   });

//   @override
//   State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
// }

// class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   final RestaurantService _restaurantService = RestaurantService();

//   // Restaurant data
//   Restaurant? _restaurant;
  
//   // Foods data
//   List<Food> _foods = [];
//   Map<String, List<Food>> _groupedFoods = {};
//   List<String> _categories = [];
  
//   // Loading states
//   bool _isLoadingRestaurant = true;
//   bool _isLoadingFoods = true;
//   bool _hasError = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     print('🍽️ RestaurantDetailScreen initState for ID: ${widget.restaurantId}');
    
//     // Initialize with length 1 first to avoid errors
//     _tabController = TabController(length: 1, vsync: this);
    
//     // Fetch all data after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         _fetchAllData();
//       }
//     });
//   }

//   // ✅ Fetch both restaurant details and foods
//   Future<void> _fetchAllData() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoadingRestaurant = true;
//       _isLoadingFoods = true;
//       _hasError = false;
//       _errorMessage = null;
//     });

//     try {
//       print('🌐 Starting to fetch data for restaurant: ${widget.restaurantId}');
      
//       // ✅ Fetch restaurant details first, then foods
//       Restaurant? restaurant;
//       Map<String, List<Food>> groupedFoods = {};
      
//       try {
//         restaurant = await _restaurantService
//             .fetchRestaurantById(widget.restaurantId)
//             .timeout(const Duration(seconds: 10));
//         print('✅ Restaurant fetched: ${restaurant.restName}');
//       } catch (e) {
//         print('❌ Failed to fetch restaurant: $e');
//         throw Exception('Failed to load restaurant details: ${e.toString()}');
//       }

//       if (!mounted) return;

//       // Update UI with restaurant info first
//       setState(() {
//         _restaurant = restaurant;
//         _isLoadingRestaurant = false;
//       });

//       // Now fetch foods
//       try {
//         groupedFoods = await _restaurantService
//             .fetchRestaurantFoodsWithCategories(widget.restaurantId)
//             .timeout(const Duration(seconds: 10));
        
//         final categories = groupedFoods.keys.toList();
//         final allFoods = groupedFoods.values.expand((list) => list).toList();

//         print('✅ Loaded ${allFoods.length} foods in ${categories.length} categories');

//         if (!mounted) return;

//         // Update TabController with correct length
//         final newLength = categories.isNotEmpty ? categories.length : 1;
//         _tabController.dispose();
//         _tabController = TabController(length: newLength, vsync: this);

//         setState(() {
//           _foods = allFoods;
//           _groupedFoods = groupedFoods;
//           _categories = categories;
//           _isLoadingFoods = false;
//         });
//       } catch (e) {
//         print('⚠️ Failed to fetch foods: $e');
//         // Don't fail the entire screen if only foods fail
//         if (!mounted) return;
//         setState(() {
//           _isLoadingFoods = false;
//           _categories = [];
//         });
//       }
//     } catch (e, stackTrace) {
//       print('❌ Critical error fetching data: $e');
//       print('📍 Stack trace: $stackTrace');
      
//       if (!mounted) return;

//       setState(() {
//         _hasError = true;
//         _isLoadingRestaurant = false;
//         _isLoadingFoods = false;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     print('🍽️ RestaurantDetailScreen disposing');
//     _tabController.dispose();
//     super.dispose();
//   }

//   String _getImageUrl(String? path) {
//     if (path == null || path.isEmpty) return '';
//     if (path.startsWith('http')) return path;
    
//     String cleanPath = path.replaceFirst("/root/choozy-backend", "");
//     return 'https://backend.zenzio.in$cleanPath';
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show loading state while fetching restaurant
//     if (_isLoadingRestaurant) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFE53935),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text(
//             'Loading...',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//         body: const Center(
//           child: CircularProgressIndicator(
//             color: Color(0xFFE53935),
//           ),
//         ),
//       );
//     }

//     // Show error state
//     if (_hasError || _restaurant == null) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFE53935),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text(
//             'Error',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(32),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.error_outline,
//                   size: 64,
//                   color: Colors.red,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Failed to load restaurant',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 if (_errorMessage != null) ...[
//                   const SizedBox(height: 8),
//                   Text(
//                     _errorMessage!,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 16),
//                 ElevatedButton.icon(
//                   onPressed: _fetchAllData,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Retry'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFE53935),
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     // Main UI with restaurant data
//     final imageUrl = _getImageUrl(_restaurant!.restLogo);
//     final name = _restaurant!.restName;
//     final address = _restaurant!.restAddress;
//     final avgCost = _restaurant!.avgCostTwo;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           // ===== AppBar with image =====
//           SliverAppBar(
//             expandedHeight: 200,
//             pinned: true,
//             backgroundColor: const Color(0xFFE53935),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.favorite_border, color: Colors.white),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.share, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               background: imageUrl.isNotEmpty
//                   ? Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Container(
//                           color: const Color(0xFFF5F5F5),
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               value: loadingProgress.expectedTotalBytes != null
//                                   ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                   : null,
//                               valueColor: const AlwaysStoppedAnimation<Color>(
//                                 Color(0xFFE53935),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                       errorBuilder: (_, error, __) {
//                         print('❌ Restaurant image load error: $error');
//                         return Container(
//                           color: const Color(0xFFF5F5F5),
//                           child: const Center(
//                             child: Icon(
//                               Icons.restaurant,
//                               size: 80,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         );
//                       },
//                     )
//                   : Container(
//                       color: const Color(0xFFF5F5F5),
//                       child: const Center(
//                         child: Icon(
//                           Icons.restaurant,
//                           size: 80,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//             ),
//           ),

//           // ===== Restaurant Info + Tabs =====
//           SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // --- Basic info ---
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         name,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2D2D2D),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         address,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF757575),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.currency_rupee,
//                             size: 16,
//                             color: Color(0xFFE53935),
//                           ),
//                           Text(
//                             '$avgCost for two',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // --- Loading/Error states for foods ---
//                 if (_isLoadingFoods)
//                   Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(32),
//                       child: Column(
//                         children: const [
//                           CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Color(0xFFE53935),
//                             ),
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'Loading menu...',
//                             style: TextStyle(color: Color(0xFF757575)),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 else if (_categories.isEmpty)
//                   const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(32),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.restaurant_menu,
//                             size: 64,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'No menu items available',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'This restaurant hasn\'t added any items yet.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 else
//                   // --- Category Tabs ---
//                   Container(
//                     color: const Color(0xFFF5F5F5),
//                     child: TabBar(
//                       controller: _tabController,
//                       isScrollable: true,
//                       labelColor: const Color(0xFFE53935),
//                       unselectedLabelColor: const Color(0xFF757575),
//                       indicatorColor: const Color(0xFFE53935),
//                       labelStyle: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       tabs: _categories.map((cat) => Tab(text: cat)).toList(),
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // ===== TabBar View =====
//           if (!_isLoadingFoods && _categories.isNotEmpty)
//             SliverFillRemaining(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: _categories
//                     .map((cat) => _buildCategoryMenu(cat))
//                     .toList(),
//               ),
//             ),
//         ],
//       ),

//       // ===== Floating Cart Button =====
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xFFE53935),
//         onPressed: () {
//           try {
//             Navigator.pushNamed(context, '/cart-rest');
//           } catch (e) {
//             print('❌ Cart navigation error: $e');
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Error opening cart: $e'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         child: const Icon(Icons.shopping_cart, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildCategoryMenu(String category) {
//     final foods = _groupedFoods[category] ?? [];
//     if (foods.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(32),
//           child: Text('No items in this category'),
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Text(
//           category,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D2D2D),
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...foods.map(_buildMenuItem),
//       ],
//     );
//   }

//   Widget _buildMenuItem(Food food) {
//     final imageUrl = _getImageUrl(food.image);
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//       ),
//       child: Row(
//         children: [
//           // Food Image
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5F5),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: imageUrl.isNotEmpty
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return const Center(
//                           child: SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           ),
//                         );
//                       },
//                       errorBuilder: (_, __, ___) => const Icon(
//                         Icons.restaurant_menu,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   )
//                 : const Icon(Icons.restaurant_menu, color: Colors.grey),
//           ),
//           const SizedBox(width: 12),
//           // Food Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     // Veg/Non-veg indicator
//                     Container(
//                       width: 16,
//                       height: 16,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: food.veg ? Colors.green : Colors.red,
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Center(
//                         child: Container(
//                           width: 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: food.veg ? Colors.green : Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         food.foodName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (food.description?.isNotEmpty ?? false) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     food.description!,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 13, color: Colors.grey),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           // Price and Add Button
//           Column(
//             children: [
//               Text(
//                 '₹${food.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () => _showAddItemSheet(food),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFE53935),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.add, color: Colors.white, size: 20),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddItemSheet(Food food) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: AddItemSheet(food: food),
//       ),
//     );
//   }
// }

// // AddItemSheet remains exactly the same
// class AddItemSheet extends StatefulWidget {
//   final Food food;
//   const AddItemSheet({super.key, required this.food});

//   @override
//   State<AddItemSheet> createState() => _AddItemSheetState();
// }

// class _AddItemSheetState extends State<AddItemSheet> {
//   int _quantity = 1;
//   String _size = 'Medium';
//   String _spice = 'Medium';

//   double get _total {
//     double base = widget.food.price;
//     double extra = _size == 'Large'
//         ? 40
//         : _size == 'Small'
//         ? -50
//         : 0;
//     return (base + extra) * _quantity;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 20,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: widget.food.veg ? Colors.green : Colors.red,
//                     width: 2,
//                   ),
//                 ),
//                 child: Center(
//                   child: Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: widget.food.veg ? Colors.green : Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   widget.food.foodName,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               Text(
//                 '₹${widget.food.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           if (widget.food.description?.isNotEmpty ?? false)
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text(
//                 widget.food.description!,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ),
//           const SizedBox(height: 24),
//           Row(
//             children: [
//               const Text(
//                 'Quantity',
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xFFE53935)),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.remove,
//                     color: Color(0xFFE53935),
//                     size: 16,
//                   ),
//                 ),
//                 onPressed: () {
//                   if (_quantity > 1) setState(() => _quantity--);
//                 },
//               ),
//               Text(
//                 '$_quantity',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               IconButton(
//                 icon: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFE53935),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.add, color: Colors.white, size: 16),
//                 ),
//                 onPressed: () => setState(() => _quantity++),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Choose your size',
//             style: TextStyle(fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           _buildSizeOption('Small', '-₹50'),
//           _buildSizeOption('Medium', '₹0'),
//           _buildSizeOption('Large', '+₹40'),
//           const SizedBox(height: 16),
//           const Text(
//             'Choose spice level',
//             style: TextStyle(fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           _buildSpiceOption('Mild'),
//           _buildSpiceOption('Medium'),
//           _buildSpiceOption('Hot'),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             height: 56,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFE53935),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             onPressed: () async {
//   final cartService = CartService();
//   // final item = CartItem(
//   //   foodId: widget.food.id,
//   //   quantity: _quantity,
//   //   selectedAddOns: [
//   //     if (_size == 'Large') AddOn(name: 'Large Size', price: 40),
//   //     if (_size == 'Small') AddOn(name: 'Small Size', price: -50),
//   //     AddOn(name: 'Spice: $_spice', price: 0),
//   //   ],
//   // );
//   final item = CartItem(
//   restaurantUid: widget.food.restaurantUid ?? "",
//   menuUid: widget.food.id,                    // <--- real id
//   menuName: widget.food.foodName,                 // <--- real name
//   price: widget.food.price ?? 0,              // <--- real price
//   qty: _quantity,
// );


//   try {
//     await cartService.addToCart(item);

//     if (!mounted) return;
//     Navigator.pop(context);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${widget.food.foodName} added to cart successfully'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   } catch (e) {
//     if (!mounted) return;
//     Navigator.pop(context);

//     // Check for different restaurant
//     if (e.toString().contains('DIFFERENT_RESTAURANT')) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Cart Conflict'),
//           content: const Text(
//               'You already have items from another restaurant. Do you want to clear your cart and add this item?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context), // Cancel
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context); // Close dialog
//                 try {
//                   await cartService.clearCart();
//                   await cartService.addToCart(item); // Retry
//                   if (!mounted) return;
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                           '${widget.food.foodName} added to cart successfully'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 } catch (err) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error: $err'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Clear & Add'),
//             ),
//           ],
//         ),
//       );
//     } else {
//       // Generic error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//       );
//     }
//   }
// },

//               child: Text(
//                 'Add to Cart - ₹${_total.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSizeOption(String size, String price) => GestureDetector(
//         onTap: () => setState(() => _size = size),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: _size == size
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFFE0E0E0),
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 _size == size
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//                 color: _size == size ? const Color(0xFFE53935) : Colors.grey,
//               ),
//               const SizedBox(width: 8),
//               Text(size),
//               const Spacer(),
//               Text(price),
//             ],
//           ),
//         ),
//       );

//   Widget _buildSpiceOption(String spice) => GestureDetector(
//         onTap: () => setState(() => _spice = spice),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: _spice == spice
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFFE0E0E0),
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 _spice == spice
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//                 color: _spice == spice ? const Color(0xFFE53935) : Colors.grey,
//               ),
//               const SizedBox(width: 8),
//               Text(spice),
//             ],
//           ),
//         ),
//       );
// }

import 'package:flutter/material.dart';
import 'package:zenzio_customer/data/models/cart_model.dart';
import 'package:zenzio_customer/services/cart_service.dart';
import '../../services/restaurant_service.dart';
import '../../data/models/food_model.dart';
import '../../data/models/restaurant_model.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String? restaurantId;
  final Map<String, dynamic>? restaurantData; // ✅ Add restaurant data parameter

  const RestaurantDetailScreen({
    super.key,
    this.restaurantId,
    this.restaurantData,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final RestaurantService _restaurantService = RestaurantService();

  // Restaurant data
  Restaurant? _restaurant;
  
  // Foods data
  List<Food> _foods = [];
  Map<String, List<Food>> _groupedFoods = {};
  List<String> _categories = [];
  
  // Loading states
  bool _isLoadingRestaurant = true;
  bool _isLoadingFoods = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🍽️ RestaurantDetailScreen initState');
    
    // Initialize with length 1 first to avoid errors
    _tabController = TabController(length: 1, vsync: this);
    
    // Fetch all data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchAllData();
      }
    });
  }

  // ✅ Get restaurant ID from either parameter
  String? get _effectiveRestaurantId {
    return widget.restaurantId ?? widget.restaurantData?['restaurant_uid'];
  }

  // ✅ Fetch both restaurant details and foods
  Future<void> _fetchAllData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRestaurant = true;
      _isLoadingFoods = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final restaurantId = _effectiveRestaurantId;
      if (restaurantId == null) {
        throw Exception('Restaurant ID not provided');
      }

      print('🌐 Starting to fetch data for restaurant: $restaurantId');
      
      Restaurant? restaurant;
      Map<String, List<Food>> groupedFoods = {};
      
      // ✅ Check if restaurant data was passed from HomeScreen
      if (widget.restaurantData != null) {
        print('✅ Using pre-loaded restaurant data from HomeScreen');
        // Convert Map to Restaurant object
        restaurant = _convertMapToRestaurant(widget.restaurantData!);
      } else {
        // Fetch restaurant details from API
        try {
          restaurant = await _restaurantService
              .fetchRestaurantById(restaurantId)
              .timeout(const Duration(seconds: 10));
          print('✅ Restaurant fetched from API: ${restaurant.restName}');
        } catch (e) {
          print('❌ Failed to fetch restaurant: $e');
          throw Exception('Failed to load restaurant details: ${e.toString()}');
        }
      }

      if (!mounted) return;

      // Update UI with restaurant info first
      setState(() {
        _restaurant = restaurant;
        _isLoadingRestaurant = false;
      });

      // Now fetch foods
      try {
        groupedFoods = await _restaurantService
            .fetchRestaurantFoodsWithCategories(restaurantId)
            .timeout(const Duration(seconds: 10));
        
        final categories = groupedFoods.keys.toList();
        final allFoods = groupedFoods.values.expand((list) => list).toList();

        print('✅ Loaded ${allFoods.length} foods in ${categories.length} categories');

        if (!mounted) return;

        // Update TabController with correct length
        final newLength = categories.isNotEmpty ? categories.length : 1;
        _tabController.dispose();
        _tabController = TabController(length: newLength, vsync: this);

        setState(() {
          _foods = allFoods;
          _groupedFoods = groupedFoods;
          _categories = categories;
          _isLoadingFoods = false;
        });
      } catch (e) {
        print('⚠️ Failed to fetch foods: $e');
        if (!mounted) return;
        setState(() {
          _isLoadingFoods = false;
          _categories = [];
        });
      }
    } catch (e, stackTrace) {
      print('❌ Critical error fetching data: $e');
      print('📍 Stack trace: $stackTrace');
      
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isLoadingRestaurant = false;
        _isLoadingFoods = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ✅ Convert Map to Restaurant object
  Restaurant _convertMapToRestaurant(Map<String, dynamic> data) {
    final profile = data['profile'] ?? {};
    final List photos = profile['photo'] ?? [];
    final String imageUrl = photos.isNotEmpty ? photos.first : "";

    return Restaurant(
      id: data['restaurant_uid'] ?? '',
      restName: data['restaurant_name'] ?? 'Unknown',
      restAddress: data['rest_address'] ?? '',
      restLogo: imageUrl,
      avgCostTwo: data['avg_cost_two']?.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    print('🍽️ RestaurantDetailScreen disposing');
    _tabController.dispose();
    super.dispose();
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    
    String cleanPath = path.replaceFirst("/root/choozy-backend", "");
    return 'https://backend.zenzio.in$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while fetching restaurant
    if (_isLoadingRestaurant) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFE53935),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Loading...',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE53935),
          ),
        ),
      );
    }

    // Show error state
    if (_hasError || _restaurant == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFE53935),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Error',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load restaurant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _fetchAllData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Main UI with restaurant data
    final imageUrl = _getImageUrl(_restaurant!.restLogo);
    final name = _restaurant!.restName;
    final address = _restaurant!.restAddress;
    final avgCost = _restaurant!.avgCostTwo;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ===== AppBar with image =====
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFFE53935),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFF5F5F5),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFE53935),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, error, __) {
                        print('❌ Restaurant image load error: $error');
                        return Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFFF5F5F5),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ),

          // ===== Restaurant Info + Tabs =====
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Basic info ---
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            size: 16,
                            color: Color(0xFFE53935),
                          ),
                          Text(
                            '$avgCost for two',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- Loading/Error states for foods ---
                if (_isLoadingFoods)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE53935),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading menu...',
                            style: TextStyle(color: Color(0xFF757575)),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_categories.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No menu items available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This restaurant hasn\'t added any items yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // --- Category Tabs ---
                  Container(
                    color: const Color(0xFFF5F5F5),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: const Color(0xFFE53935),
                      unselectedLabelColor: const Color(0xFF757575),
                      indicatorColor: const Color(0xFFE53935),
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: _categories.map((cat) => Tab(text: cat)).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // ===== TabBar View =====
          if (!_isLoadingFoods && _categories.isNotEmpty)
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: _categories
                    .map((cat) => _buildCategoryMenu(cat))
                    .toList(),
              ),
            ),
        ],
      ),

      // ===== Floating Cart Button =====
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE53935),
        onPressed: () {
          try {
            Navigator.pushNamed(context, '/cart-rest');
          } catch (e) {
            print('❌ Cart navigation error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error opening cart: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryMenu(String category) {
    final foods = _groupedFoods[category] ?? [];
    if (foods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No items in this category'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          category,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 12),
        ...foods.map(_buildMenuItem),
      ],
    );
  }

  Widget _buildMenuItem(Food food) {
    final imageUrl = _getImageUrl(food.image);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          // Food Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.restaurant_menu,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : const Icon(Icons.restaurant_menu, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // Food Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Veg/Non-veg indicator
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: food.veg ? Colors.green : Colors.red,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: food.veg ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        food.foodName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (food.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    food.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          // Price and Add Button
          Column(
            children: [
              Text(
                '₹${food.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showAddItemSheet(food),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddItemSheet(Food food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddItemSheet(food: food),
      ),
    );
  }
}

// AddItemSheet remains the same...
class AddItemSheet extends StatefulWidget {
  final Food food;
  const AddItemSheet({super.key, required this.food});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  int _quantity = 1;
  String _size = 'Medium';
  String _spice = 'Medium';

  double get _total {
    double base = widget.food.price;
    double extra = _size == 'Large'
        ? 40
        : _size == 'Small'
        ? -50
        : 0;
    return (base + extra) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.food.veg ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.food.veg ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.food.foodName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '₹${widget.food.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          if (widget.food.description?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.food.description!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Quantity',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE53935)),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Color(0xFFE53935),
                    size: 16,
                  ),
                ),
                onPressed: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
              ),
              Text(
                '$_quantity',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose your size',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildSizeOption('Small', '-₹50'),
          _buildSizeOption('Medium', '₹0'),
          _buildSizeOption('Large', '+₹40'),
          const SizedBox(height: 16),
          const Text(
            'Choose spice level',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildSpiceOption('Mild'),
          _buildSpiceOption('Medium'),
          _buildSpiceOption('Hot'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final cartService = CartService();
                final item = CartItem(
                  restaurantUid: widget.food.restaurantUid ?? "",
                  menuUid: widget.food.id,
                  menuName: widget.food.foodName,
                  price: widget.food.price ?? 0,
                  qty: _quantity,
                );

                try {
                  await cartService.addToCart(item);

                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.food.foodName} added to cart successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);

                  if (e.toString().contains('DIFFERENT_RESTAURANT')) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cart Conflict'),
                        content: const Text(
                            'You already have items from another restaurant. Do you want to clear your cart and add this item?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                await cartService.clearCart();
                                await cartService.addToCart(item);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${widget.food.foodName} added to cart successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (err) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $err'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text('Clear & Add'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text(
                'Add to Cart - ₹${_total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String size, String price) => GestureDetector(
        onTap: () => setState(() => _size = size),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _size == size
                  ? const Color(0xFFE53935)
                  : const Color(0xFFE0E0E0),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                _size == size
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: _size == size ? const Color(0xFFE53935) : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(size),
              const Spacer(),
              Text(price),
            ],
          ),
        ),
      );

  Widget _buildSpiceOption(String spice) => GestureDetector(
        onTap: () => setState(() => _spice = spice),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _spice == spice
                  ? const Color(0xFFE53935)
                  : const Color(0xFFE0E0E0),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                _spice == spice
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: _spice == spice ? const Color(0xFFE53935) : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(spice),
            ],
          ),
        ),
      );
}