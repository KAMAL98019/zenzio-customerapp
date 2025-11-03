// import 'package:flutter/material.dart';

// class RestaurantDetailScreen extends StatefulWidget {
//   const RestaurantDetailScreen({super.key, required String restaurantId, required restaurant});

//   @override
//   State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
// }

// class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 5, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200,
//             pinned: true,
//             backgroundColor: const Color(0xFFE53935),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.favorite_border),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.share),
//                 onPressed: () {},
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 color: const Color(0xFFF5F5F5),
//                 child: const Center(
//                   child: Icon(
//                     Icons.restaurant,
//                     size: 80,
//                     color: Color(0xFFE0E0E0),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Expanded(
//                             child: Text(
//                               'Urban Bistro',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF2D2D2D),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFE53935),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: const Row(
//                               children: [
//                                 Icon(Icons.star, color: Colors.white, size: 14),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   '4.5',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Modern European cuisine in a casual setting',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF757575),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   color: const Color(0xFFF5F5F5),
//                   child: TabBar(
//                     controller: _tabController,
//                     isScrollable: true,
//                     labelColor: const Color(0xFFE53935),
//                     unselectedLabelColor: const Color(0xFF757575),
//                     indicatorColor: const Color(0xFFE53935),
//                     labelStyle: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     tabs: const [
//                       Tab(text: 'Food Menu'),
//                       Tab(text: 'Dining & Events'),
//                       Tab(text: 'Starts'),
//                       Tab(text: 'Main Course'),
//                       Tab(text: 'Desserts'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: MediaQuery.of(context).size.height - 300,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildFoodMenu(),
//                   _buildDiningEvents(),
//                   _buildStarters(),
//                   _buildMainCourse(),
//                   _buildDesserts(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.pushNamed(context, '/cart');
//         },
//         backgroundColor: const Color(0xFFE53935),
//         foregroundColor: const Color.fromARGB(255, 243, 241, 241),
//         child: const Icon(Icons.shopping_cart),
//       ),
//     );
//   }

//   Widget _buildFoodMenu() {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         const Text(
//           'Starts',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D2D2D),
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildMenuItem(
//           'Truffle Arancini',
//           'Italian rice balls with truffle and parmesan',
//           '₹129',
//         ),
//         _buildMenuItem(
//           'Bruschetta',
//           'Classic Italian starter with fresh basil',
//           '₹999',
//         ),
//         _buildMenuItem(
//           'Calamari',
//           'Crispy fried squid with lemon aioli',
//           '₹149',
//         ),
//         _buildMenuItem(
//           'Shrimp Cocktail',
//           'Chilled jumbo shrimp with cocktail sauce',
//           '₹169',
//         ),
//         const SizedBox(height: 24),
//         const Text(
//           'Main Course',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D2D2D),
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildMenuItem(
//           'Ribeye Steak',
//           'Grilled to perfection with garlic butter',
//           '₹289',
//         ),
//       ],
//     );
//   }

//   Widget _buildDiningEvents() {
//     return const Center(
//       child: Text('Dining & Events Content'),
//     );
//   }

//   Widget _buildStarters() {
//     return const Center(
//       child: Text('Starters Content'),
//     );
//   }

//   Widget _buildMainCourse() {
//     return const Center(
//       child: Text('Main Course Content'),
//     );
//   }

//   Widget _buildDesserts() {
//     return const Center(
//       child: Text('Desserts Content'),
//     );
//   }

//   Widget _buildMenuItem(String name, String description, String price) {
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
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5F5),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(
//               Icons.restaurant_menu,
//               color: Color(0xFFE0E0E0),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF757575),
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             children: [
//               Text(
//                 price,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2D2D2D),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () {
//                   _showAddItemSheet(name, price);
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFE53935),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.add,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddItemSheet(String itemName, String price) {
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
//         child: AddItemSheet(itemName: itemName, price: price),
//       ),
//     );
//   }
// }

// class AddItemSheet extends StatefulWidget {
//   final String itemName;
//   final String price;

//   const AddItemSheet({
//     super.key,
//     required this.itemName,
//     required this.price,
//   });

//   @override
//   State<AddItemSheet> createState() => _AddItemSheetState();
// }

// class _AddItemSheetState extends State<AddItemSheet> {
//   int _quantity = 1;
//   String _selectedSize = 'Medium';
//   String _selectedSpice = 'Medium';

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.itemName,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                 ),
//                 Text(
//                   widget.price,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFFE53935),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 const Text(
//                   'Quantity',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   onPressed: () {
//                     if (_quantity > 1) {
//                       setState(() => _quantity--);
//                     }
//                   },
//                   icon: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: const Color(0xFFE53935)),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.remove,
//                       color: Color(0xFFE53935),
//                       size: 20,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     '$_quantity',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     setState(() => _quantity++);
//                   },
//                   icon: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFE53935),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.add,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Choose your size',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildSizeOption('Small', '₹50'),
//             _buildSizeOption('Medium', '₹0'),
//             _buildSizeOption('Large', '₹40'),
//             const SizedBox(height: 24),
//             const Text(
//               'Choose your spice level',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildSpiceOption('Mild'),
//             _buildSpiceOption('Medium'),
//             _buildSpiceOption('Hot'),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Item added to cart'),
//                       backgroundColor: Color(0xFF4CAF50),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text(
//                   'Add to Cart - ${widget.price}',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSizeOption(String size, String extraPrice) {
//     return GestureDetector(
//       onTap: () => setState(() => _selectedSize = size),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: _selectedSize == size
//                 ? const Color(0xFFE53935)
//                 : const Color(0xFFE0E0E0),
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               _selectedSize == size
//                   ? Icons.radio_button_checked
//                   : Icons.radio_button_unchecked,
//               color: _selectedSize == size
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFF9E9E9E),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               size,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const Spacer(),
//             Text(
//               extraPrice,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSpiceOption(String spice) {
//     return GestureDetector(
//       onTap: () => setState(() => _selectedSpice = spice),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: _selectedSpice == spice
//                 ? const Color(0xFFE53935)
//                 : const Color(0xFFE0E0E0),
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               _selectedSpice == spice
//                   ? Icons.radio_button_checked
//                   : Icons.radio_button_unchecked,
//               color: _selectedSpice == spice
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFF9E9E9E),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               spice,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:zenzio_customer/data/models/cart_model.dart';
import 'package:zenzio_customer/services/cart_service.dart';
import '../services/restaurant_service.dart';
import '../data/models/food_model.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final Map<String, dynamic> restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

// ✅ CRITICAL FIX: Changed from SingleTickerProviderStateMixin to TickerProviderStateMixin
class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with TickerProviderStateMixin {  // ← Changed here
  late TabController _tabController;
  final RestaurantService _restaurantService = RestaurantService();

  List<Food> _foods = [];
  Map<String, List<Food>> _groupedFoods = {};
  List<String> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🍽️ RestaurantDetailScreen initState for: ${widget.restaurant['rest_name']}');
    
    // ✅ Initialize with length 1 first to avoid errors
    _tabController = TabController(length: 1, vsync: this);
    
    // ✅ Fetch data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchRestaurantFoods();
      }
    });
  }

  Future<void> _fetchRestaurantFoods() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      print('🌐 Fetching foods for restaurant: ${widget.restaurantId}');
      
      final grouped = await _restaurantService
          .fetchRestaurantFoodsWithCategories(widget.restaurantId)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timeout - please check your connection');
            },
          );

      if (!mounted) return;

      final categories = grouped.keys.toList();
      final allFoods = grouped.values.expand((list) => list).toList();

      print('✅ Loaded ${allFoods.length} foods in ${categories.length} categories');

      // ✅ Safely update TabController
      final newLength = categories.isNotEmpty ? categories.length : 1;
      
      // Dispose old controller
      _tabController.dispose();
      
      // Create new controller with correct length
      _tabController = TabController(
        length: newLength,
        vsync: this,
      );

      if (mounted) {
        setState(() {
          _foods = allFoods;
          _groupedFoods = grouped;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching foods: $e');
      print('📍 Stack trace: $stackTrace');
      
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
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
    print('🍽️ RestaurantDetailScreen building...');
    
    final restaurant = widget.restaurant;
    final imageUrl = _getImageUrl(restaurant['rest_logo']);
    final name = restaurant['rest_name']?.toString() ?? 'Restaurant';
    final address = restaurant['rest_address']?.toString() ?? '';
    final avgCost = restaurant['avg_cost_two']?.toString() ?? '0';

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

                // --- Loading/Error states ---
                if (_isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: const [
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
                else if (_hasError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load menu',
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
                            onPressed: _fetchRestaurantFoods,
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
          if (!_isLoading && !_hasError && _categories.isNotEmpty)
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
            Navigator.pushNamed(context, '/cart');
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
        ...foods.map(_buildMenuItem).toList(),
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

// Rest of the AddItemSheet code remains the same...

// AddItemSheet remains exactly the same - no changes needed
class AddItemSheet extends StatefulWidget {
  final Food food;
  const AddItemSheet({super.key, required this.food});
  
  get restaurantId => null;

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
              // Veg/Non-veg indicator
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
          // Quantity
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
                try {
                  final cartService = CartService();

                 final item = CartItem(
  restaurantId: widget.restaurantId,
  foodId: widget.food.id,
  quantity: _quantity,
  selectedAddOns: [
    if (_size == 'Large') AddOn(name: 'Large Size', price: 40),
    if (_size == 'Small') AddOn(name: 'Small Size', price: -50),
    AddOn(name: 'Spice: $_spice', price: 0),
  ],
);


                  final success = await cartService.addToCart(item);

                  if (!mounted) return;
                  Navigator.pop(context);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${widget.food.foodName} added to cart successfully',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add item to cart'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  print('❌ Add to cart error: $e');
                  if (!mounted) return;
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
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